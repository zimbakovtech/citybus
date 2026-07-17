from sqlalchemy import BigInteger, Identity, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Service(Base):
    """Logical service pattern (normalized GTFS service_id).

    GTFS has no services.txt; the id appears in calendar.txt, calendar_dates.txt
    and trips.txt. Normalizing it into its own table lets all three reference one
    entity and supports feeds that only use calendar_dates.
    """

    __tablename__ = "services"

    id: Mapped[int] = mapped_column(BigInteger, Identity(always=True), primary_key=True)
    gtfs_service_id: Mapped[str] = mapped_column(Text, unique=True)
