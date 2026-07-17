from geoalchemy2 import Geometry, WKBElement
from sqlalchemy import BigInteger, ForeignKey, Identity, SmallInteger, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Stop(Base):
    """Physical bus stop or station (GTFS stops.txt)."""

    __tablename__ = "stops"

    id: Mapped[int] = mapped_column(BigInteger, Identity(always=True), primary_key=True)
    gtfs_stop_id: Mapped[str] = mapped_column(Text, unique=True)
    code: Mapped[str | None] = mapped_column(Text)
    name: Mapped[str] = mapped_column(Text)
    description: Mapped[str | None] = mapped_column(Text)
    lat: Mapped[float]
    lon: Mapped[float]
    # mirrors lat/lon as a PostGIS point; indexed with GiST (02_indexes.sql)
    geom: Mapped[WKBElement] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326, spatial_index=False)
    )
    location_type: Mapped[int] = mapped_column(SmallInteger, default=0, server_default="0")
    parent_station_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("stops.id", ondelete="SET NULL")
    )
