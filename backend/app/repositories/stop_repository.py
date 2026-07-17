"""Stop queries: text search, spatial nearby-search, detail, departures."""

from datetime import date, timedelta

from sqlalchemy import Row, func, select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Route, Stop, StopTime, Trip


class StopRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get(self, stop_id: int) -> Stop | None:
        return await self.session.get(Stop, stop_id)

    async def search(self, query: str | None, limit: int, offset: int) -> tuple[list[Stop], int]:
        stmt = select(Stop)
        if query:
            # trigram-indexed fuzzy match (idx_stops_name_trgm)
            stmt = stmt.where(Stop.name.ilike(f"%{query}%"))
        total = await self.session.scalar(select(func.count()).select_from(stmt.subquery()))
        result = await self.session.scalars(
            stmt.order_by(Stop.name, Stop.id).limit(limit).offset(offset)
        )
        return list(result), total or 0

    async def nearby(self, lat: float, lon: float, radius_m: float, limit: int) -> list[Row]:
        """Stops within radius_m of a point, nearest first.

        ST_DWithin on geography gives a correct meter-based filter; the KNN
        operator (<->) orders by distance using the GiST index.
        """
        result = await self.session.execute(
            text(
                """
                SELECT id, name, code, lat, lon,
                       ST_Distance(
                           geom::geography,
                           ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography
                       ) AS distance_m
                FROM stops
                WHERE ST_DWithin(
                          geom::geography,
                          ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography,
                          :radius_m
                      )
                ORDER BY geom <-> ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)
                LIMIT :limit
                """
            ),
            {"lat": lat, "lon": lon, "radius_m": radius_m, "limit": limit},
        )
        return list(result)

    async def nearest_stop_id(self, lat: float, lon: float) -> int | None:
        """The single nearest stop to a point (used to snap planner coordinates)."""
        return await self.session.scalar(
            text(
                """
                SELECT id FROM stops
                ORDER BY geom <-> ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)
                LIMIT 1
                """
            ),
            {"lat": lat, "lon": lon},
        )

    async def routes_serving_stop(self, stop_id: int) -> list[Route]:
        """Distinct routes with at least one trip calling at this stop."""
        result = await self.session.scalars(
            select(Route)
            .join(Trip, Trip.route_id == Route.id)
            .join(StopTime, StopTime.trip_id == Trip.id)
            .where(StopTime.stop_id == stop_id)
            .distinct()
            .order_by(Route.id)
        )
        return list(result)

    async def departures(
        self,
        stop_id: int,
        service_ids: list[int],
        window_start: timedelta,
        window_end: timedelta,
        service_date: date,
    ) -> list[Row]:
        """Scheduled departures at a stop for the given active services, with
        departure_time (interval since service midnight) inside the window.

        The caller handles after-midnight service by invoking this twice: once
        for today's services and once for yesterday's services with the window
        shifted by +24h (yesterday's trips running past 24:00:00 today).
        """
        if not service_ids:
            return []
        result = await self.session.execute(
            select(
                StopTime.trip_id,
                StopTime.stop_sequence,
                StopTime.departure_time,
                Trip.headsign,
                Route.id.label("route_id"),
                Route.short_name,
                Route.long_name,
                Route.color,
            )
            .join(Trip, Trip.id == StopTime.trip_id)
            .join(Route, Route.id == Trip.route_id)
            .where(
                StopTime.stop_id == stop_id,
                Trip.service_id.in_(service_ids),
                StopTime.departure_time >= window_start,
                StopTime.departure_time <= window_end,
                # departures only: skip the trip's final stop
                StopTime.stop_sequence
                < select(func.max(StopTime.stop_sequence))
                .where(StopTime.trip_id == Trip.id)
                .correlate(Trip)
                .scalar_subquery(),
            )
            .order_by(StopTime.departure_time)
        )
        _ = service_date  # kept for symmetry/logging; date itself not needed in SQL
        return list(result)
