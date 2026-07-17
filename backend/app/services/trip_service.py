"""Trip use-cases: detail with ordered stop_times."""

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundError
from app.core.gtfs_time import format_interval
from app.repositories.trip_repository import TripRepository
from app.schemas.route import RouteSummary
from app.schemas.stop import StopSummary
from app.schemas.trip import TripDetail, TripStopTime


class TripService:
    def __init__(self, session: AsyncSession):
        self.trips = TripRepository(session)

    async def detail(self, trip_id: int) -> TripDetail:
        trip = await self.trips.get_with_route(trip_id)
        if trip is None:
            raise NotFoundError("trip", trip_id)
        rows = await self.trips.stop_times_for_trip(trip_id)
        return TripDetail(
            id=trip.id,
            gtfs_trip_id=trip.gtfs_trip_id,
            route=RouteSummary.model_validate(trip.route, from_attributes=True),
            headsign=trip.headsign,
            direction_id=trip.direction_id,
            stop_times=[
                TripStopTime(
                    stop_sequence=row.stop_sequence,
                    stop=StopSummary(
                        id=row.id, name=row.name, code=row.code, lat=row.lat, lon=row.lon
                    ),
                    arrival_time=format_interval(row.arrival_time),
                    departure_time=format_interval(row.departure_time),
                )
                for row in rows
            ],
        )
