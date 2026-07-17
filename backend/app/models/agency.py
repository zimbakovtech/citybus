from sqlalchemy import BigInteger, Identity, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Agency(Base):
    """Transit operator (GTFS agency.txt)."""

    __tablename__ = "agency"

    id: Mapped[int] = mapped_column(BigInteger, Identity(always=True), primary_key=True)
    gtfs_agency_id: Mapped[str] = mapped_column(Text, unique=True)
    name: Mapped[str] = mapped_column(Text)
    url: Mapped[str | None] = mapped_column(Text)
    timezone: Mapped[str] = mapped_column(Text)
    lang: Mapped[str | None] = mapped_column(Text)
    phone: Mapped[str | None] = mapped_column(Text)
