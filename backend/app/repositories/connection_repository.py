"""Builds the CSA connection array from stop_times.

Consecutive stop_times of a trip are paired with a LEAD window function, so the
query does not assume stop_sequence values are gapless (GTFS only requires them
to increase)."""

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.csa import Connection

CONNECTIONS_SQL = text(
    """
    SELECT dep_stop, arr_stop, dep_time, arr_time, trip_id, dep_sequence, route_id
    FROM (
        SELECT st.stop_id                                   AS dep_stop,
               LEAD(st.stop_id) OVER w                      AS arr_stop,
               EXTRACT(EPOCH FROM st.departure_time)::int   AS dep_time,
               EXTRACT(EPOCH FROM LEAD(st.arrival_time) OVER w)::int AS arr_time,
               st.trip_id                                   AS trip_id,
               st.stop_sequence                             AS dep_sequence,
               t.route_id                                   AS route_id
        FROM stop_times st
        JOIN trips t ON t.id = st.trip_id
        WHERE t.service_id = ANY(:service_ids)
        WINDOW w AS (PARTITION BY st.trip_id ORDER BY st.stop_sequence)
    ) hops
    WHERE arr_stop IS NOT NULL
    ORDER BY dep_time
    """
)


class ConnectionRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def connections_for_services(
        self, service_ids: list[int], time_offset_s: int = 0
    ) -> list[Connection]:
        """All connections of the given services, times shifted by
        time_offset_s (e.g. -86400 to express yesterday's after-midnight trips
        in today's clock). Sorted by departure time."""
        if not service_ids:
            return []
        result = await self.session.execute(CONNECTIONS_SQL, {"service_ids": service_ids})
        return [
            Connection(
                dep_stop=row.dep_stop,
                arr_stop=row.arr_stop,
                dep_time=row.dep_time + time_offset_s,
                arr_time=row.arr_time + time_offset_s,
                trip_id=row.trip_id,
                dep_sequence=row.dep_sequence,
                route_id=row.route_id,
            )
            for row in result
        ]
