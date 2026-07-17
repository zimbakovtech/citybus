"""Active-service resolution: which GTFS services run on a given date.

A service is active on date D when:
  * calendar_dates has an exception for (service, D): type 1 -> active,
    type 2 -> inactive (exceptions always win), otherwise
  * calendar says so: D within [start_date, end_date] and D's weekday flag set.
"""

from datetime import date

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

ACTIVE_SERVICES_SQL = text(
    """
    SELECT s.id
    FROM services s
    LEFT JOIN calendar c ON c.service_id = s.id
    LEFT JOIN calendar_dates cd ON cd.service_id = s.id AND cd.date = :service_date
    WHERE CASE
        WHEN cd.exception_type = 1 THEN true
        WHEN cd.exception_type = 2 THEN false
        ELSE c.service_id IS NOT NULL
             AND :service_date BETWEEN c.start_date AND c.end_date
             -- Postgres dow: 0 = Sunday .. 6 = Saturday
             AND (ARRAY[c.sunday, c.monday, c.tuesday, c.wednesday,
                        c.thursday, c.friday, c.saturday]
                 )[EXTRACT(dow FROM CAST(:service_date AS date))::int + 1]
    END
    """
)


class ServiceRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def active_service_ids(self, service_date: date) -> list[int]:
        result = await self.session.execute(ACTIVE_SERVICES_SQL, {"service_date": service_date})
        return [row.id for row in result]
