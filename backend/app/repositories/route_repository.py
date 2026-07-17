"""Route queries: search, detail, ordered stops, shape polyline, trips by date."""

import json

from sqlalchemy import Row, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Agency, Route, Shape, Stop, StopTime, Trip


class RouteRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get(self, route_id: int) -> Route | None:
        return await self.session.get(Route, route_id)

    async def get_with_agency(self, route_id: int) -> Row | None:
        result = await self.session.execute(
            select(Route, Agency.name.label("agency_name"))
            .join(Agency, Agency.id == Route.agency_id)
            .where(Route.id == route_id)
        )
        return result.first()

    async def search(self, query: str | None, limit: int, offset: int) -> tuple[list[Route], int]:
        stmt = select(Route)
        if query:
            # trigram-indexed match on either name (idx_routes_*_trgm)
            pattern = f"%{query}%"
            stmt = stmt.where(or_(Route.short_name.ilike(pattern), Route.long_name.ilike(pattern)))
        total = await self.session.scalar(select(func.count()).select_from(stmt.subquery()))
        result = await self.session.scalars(stmt.order_by(Route.id).limit(limit).offset(offset))
        return list(result), total or 0

    async def _representative_trip_id(self, route_id: int, direction_id: int | None) -> int | None:
        """The trip with the most stops for this route/direction — used as the
        canonical stop sequence for display."""
        stmt = (
            select(Trip.id)
            .join(StopTime, StopTime.trip_id == Trip.id)
            .where(Trip.route_id == route_id)
            .group_by(Trip.id)
            .order_by(func.count().desc(), Trip.id)
            .limit(1)
        )
        if direction_id is not None:
            stmt = stmt.where(Trip.direction_id == direction_id)
        return await self.session.scalar(stmt)

    async def ordered_stops(self, route_id: int, direction_id: int | None) -> list[Row]:
        trip_id = await self._representative_trip_id(route_id, direction_id)
        if trip_id is None:
            return []
        result = await self.session.execute(
            select(Stop.id, Stop.name, Stop.code, Stop.lat, Stop.lon, StopTime.stop_sequence)
            .join(StopTime, StopTime.stop_id == Stop.id)
            .where(StopTime.trip_id == trip_id)
            .order_by(StopTime.stop_sequence)
        )
        return list(result)

    async def shape_geojson(self, route_id: int, direction_id: int | None) -> dict | None:
        """The route's polyline as a GeoJSON geometry dict (via ST_AsGeoJSON)."""
        stmt = (
            select(func.ST_AsGeoJSON(Shape.geom))
            .join(Trip, Trip.shape_id == Shape.id)
            .where(Trip.route_id == route_id, Shape.geom.is_not(None))
            .limit(1)
        )
        if direction_id is not None:
            stmt = stmt.where(Trip.direction_id == direction_id)
        geojson = await self.session.scalar(stmt)
        return json.loads(geojson) if geojson else None

    async def trips_on_date(self, route_id: int, service_ids: list[int]) -> list[Row]:
        if not service_ids:
            return []
        first_dep = (
            select(func.min(StopTime.departure_time))
            .where(StopTime.trip_id == Trip.id)
            .correlate(Trip)
            .scalar_subquery()
        )
        last_arr = (
            select(func.max(StopTime.arrival_time))
            .where(StopTime.trip_id == Trip.id)
            .correlate(Trip)
            .scalar_subquery()
        )
        result = await self.session.execute(
            select(
                Trip.id,
                Trip.headsign,
                Trip.direction_id,
                first_dep.label("starts_at"),
                last_arr.label("ends_at"),
            )
            .where(Trip.route_id == route_id, Trip.service_id.in_(service_ids))
            .order_by(first_dep)
        )
        return list(result)
