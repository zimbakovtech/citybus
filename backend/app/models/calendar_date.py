from datetime import date

from sqlalchemy import (
    BigInteger,
    CheckConstraint,
    Date,
    ForeignKey,
    Identity,
    SmallInteger,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class CalendarDate(Base):
    """Date-specific exception to the weekly calendar (GTFS calendar_dates.txt)."""

    __tablename__ = "calendar_dates"
    __table_args__ = (
        CheckConstraint("exception_type IN (1, 2)", name="calendar_dates_exception_type_check"),
        UniqueConstraint("service_id", "date"),
    )

    id: Mapped[int] = mapped_column(BigInteger, Identity(always=True), primary_key=True)
    service_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("services.id", ondelete="CASCADE")
    )
    date: Mapped[date] = mapped_column(Date)
    # GTFS enum: 1 = service added on this date, 2 = removed
    exception_type: Mapped[int] = mapped_column(SmallInteger)
