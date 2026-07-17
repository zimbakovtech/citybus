"""Trip queries: detail with ordered stop_times."""

from sqlalchemy import Row, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import joinedload

from app.models import Stop, StopTime, Trip


class TripRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_with_route(self, trip_id: int) -> Trip | None:
        result = await self.session.scalars(
            select(Trip).options(joinedload(Trip.route)).where(Trip.id == trip_id)
        )
        return result.first()

    async def stop_times_for_trip(self, trip_id: int) -> list[Row]:
        result = await self.session.execute(
            select(
                StopTime.stop_sequence,
                StopTime.arrival_time,
                StopTime.departure_time,
                Stop.id,
                Stop.name,
                Stop.code,
                Stop.lat,
                Stop.lon,
            )
            .join(Stop, Stop.id == StopTime.stop_id)
            .where(StopTime.trip_id == trip_id)
            .order_by(StopTime.stop_sequence)
        )
        return list(result)
