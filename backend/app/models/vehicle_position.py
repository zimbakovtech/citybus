from datetime import datetime

from geoalchemy2 import Geometry, WKBElement
from sqlalchemy import BigInteger, ForeignKey, Identity, Integer, Text, text
from sqlalchemy.dialects.postgresql import TIMESTAMP
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class VehiclePosition(Base):
    """Append-only log of (simulated) realtime vehicle positions.

    The latest row per vehicle_id is the live state; history stays queryable.
    """

    __tablename__ = "vehicle_positions"

    id: Mapped[int] = mapped_column(BigInteger, Identity(always=True), primary_key=True)
    vehicle_id: Mapped[str] = mapped_column(Text)
    trip_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("trips.id", ondelete="SET NULL")
    )
    lat: Mapped[float]
    lon: Mapped[float]
    geom: Mapped[WKBElement] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326, spatial_index=False)
    )
    # positive = late, negative = early
    delay_seconds: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    current_stop_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("stops.id", ondelete="SET NULL")
    )
    recorded_at: Mapped[datetime] = mapped_column(
        TIMESTAMP(timezone=True), server_default=text("now()")
    )
