"""Vehicle position queries: segment lookup for the simulator, position
inserts, and the latest-per-vehicle live snapshot."""

from sqlalchemy import Row, insert, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import VehiclePosition

# For each trip of the given services that is under way at :now_s (seconds
# since that service day's midnight), return the segment between the two
# consecutive stops the vehicle is currently traveling.
ACTIVE_SEGMENTS_SQL = text(
    """
    WITH segments AS (
        SELECT st.trip_id,
               t.route_id,
               r.short_name                                          AS route_short_name,
               st.stop_id                                            AS dep_stop_id,
               LEAD(st.stop_id) OVER w                               AS arr_stop_id,
               EXTRACT(EPOCH FROM st.departure_time)::int            AS dep_s,
               EXTRACT(EPOCH FROM LEAD(st.arrival_time) OVER w)::int AS arr_s
        FROM stop_times st
        JOIN trips t  ON t.id = st.trip_id
        JOIN routes r ON r.id = t.route_id
        WHERE t.service_id = ANY(:service_ids)
        WINDOW w AS (PARTITION BY st.trip_id ORDER BY st.stop_sequence)
    )
    SELECT seg.trip_id, seg.route_short_name, seg.dep_s, seg.arr_s,
           dep.lat AS dep_lat, dep.lon AS dep_lon,
           arr.lat AS arr_lat, arr.lon AS arr_lon,
           arr.id  AS next_stop_id
    FROM segments seg
    JOIN stops dep ON dep.id = seg.dep_stop_id
    JOIN stops arr ON arr.id = seg.arr_stop_id
    WHERE seg.arr_stop_id IS NOT NULL
      AND :now_s >= seg.dep_s AND :now_s < seg.arr_s
    ORDER BY seg.trip_id
    LIMIT :max_vehicles
    """
)

# latest position per vehicle, no older than :max_age_s
LATEST_POSITIONS_SQL = text(
    """
    SELECT DISTINCT ON (vp.vehicle_id)
           vp.vehicle_id, vp.trip_id, vp.lat, vp.lon, vp.delay_seconds,
           vp.current_stop_id, vp.recorded_at, r.short_name AS route_short_name
    FROM vehicle_positions vp
    LEFT JOIN trips t  ON t.id = vp.trip_id
    LEFT JOIN routes r ON r.id = t.route_id
    WHERE vp.recorded_at > now() - make_interval(secs => :max_age_s)
    ORDER BY vp.vehicle_id, vp.recorded_at DESC
    """
)


class VehiclePositionRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def active_segments(
        self, service_ids: list[int], now_s: int, max_vehicles: int
    ) -> list[Row]:
        if not service_ids:
            return []
        result = await self.session.execute(
            ACTIVE_SEGMENTS_SQL,
            {"service_ids": service_ids, "now_s": now_s, "max_vehicles": max_vehicles},
        )
        return list(result)

    async def insert_positions(self, rows: list[dict]) -> None:
        if rows:
            await self.session.execute(insert(VehiclePosition), rows)

    async def latest_positions(self, max_age_s: int = 60) -> list[Row]:
        result = await self.session.execute(LATEST_POSITIONS_SQL, {"max_age_s": max_age_s})
        return list(result)
