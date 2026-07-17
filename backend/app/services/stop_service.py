"""Stop use-cases: search, nearby, detail, upcoming departures."""

from datetime import datetime, timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundError
from app.repositories.service_repository import ServiceRepository
from app.repositories.stop_repository import StopRepository
from app.schemas.common import Page
from app.schemas.route import RouteSummary
from app.schemas.stop import Departure, StopDetail, StopSummary, StopWithDistance


class StopService:
    def __init__(self, session: AsyncSession):
        self.stops = StopRepository(session)
        self.services = ServiceRepository(session)

    async def search(self, query: str | None, limit: int, offset: int) -> Page[StopSummary]:
        stops, total = await self.stops.search(query, limit, offset)
        return Page(
            items=[StopSummary.model_validate(s, from_attributes=True) for s in stops],
            total=total,
            limit=limit,
            offset=offset,
        )

    async def nearby(
        self, lat: float, lon: float, radius_m: float, limit: int
    ) -> list[StopWithDistance]:
        rows = await self.stops.nearby(lat, lon, radius_m, limit)
        return [StopWithDistance.model_validate(r, from_attributes=True) for r in rows]

    async def detail(self, stop_id: int) -> StopDetail:
        stop = await self.stops.get(stop_id)
        if stop is None:
            raise NotFoundError("stop", stop_id)
        routes = await self.stops.routes_serving_stop(stop_id)
        return StopDetail(
            id=stop.id,
            name=stop.name,
            code=stop.code,
            lat=stop.lat,
            lon=stop.lon,
            description=stop.description,
            routes=[RouteSummary.model_validate(r, from_attributes=True) for r in routes],
        )

    async def departures(self, stop_id: int, at: datetime, window_min: int) -> list[Departure]:
        """Departures in [at, at + window].

        GTFS times are intervals since each service day's midnight and may
        exceed 24:00:00, so a moment belongs to up to three service days:
        yesterday (running late past midnight), today, and tomorrow (when the
        window itself crosses midnight). Query each with a shifted window.
        """
        if await self.stops.get(stop_id) is None:
            raise NotFoundError("stop", stop_id)

        time_of_day = timedelta(hours=at.hour, minutes=at.minute, seconds=at.second)
        window = timedelta(minutes=window_min)
        departures: list[Departure] = []

        for day_offset in (-1, 0, 1):
            service_date = at.date() + timedelta(days=day_offset)
            # shift the window into that service day's clock
            start = time_of_day - timedelta(days=day_offset)
            end = start + window
            if end < timedelta(0):
                continue
            service_ids = await self.services.active_service_ids(service_date)
            rows = await self.stops.departures(
                stop_id, service_ids, max(start, timedelta(0)), end, service_date
            )
            midnight = datetime.combine(service_date, datetime.min.time())
            for row in rows:
                departures.append(
                    Departure(
                        trip_id=row.trip_id,
                        route=RouteSummary(
                            id=row.route_id,
                            short_name=row.short_name,
                            long_name=row.long_name,
                            color=row.color,
                        ),
                        headsign=row.headsign,
                        departure_at=midnight + row.departure_time,
                        stop_sequence=row.stop_sequence,
                    )
                )

        departures.sort(key=lambda d: d.departure_at)
        return departures
