from geoalchemy2 import Geometry, WKBElement
from sqlalchemy import BigInteger, Identity, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Shape(Base):
    """Drawable polyline of a trip path (GTFS shapes.txt header).

    geom is assembled from the ordered shape_points rows at import time, so a
    route polyline is a single-row fetch.
    """

    __tablename__ = "shapes"

    id: Mapped[int] = mapped_column(BigInteger, Identity(always=True), primary_key=True)
    gtfs_shape_id: Mapped[str] = mapped_column(Text, unique=True)
    geom: Mapped[WKBElement | None] = mapped_column(
        Geometry(geometry_type="LINESTRING", srid=4326, spatial_index=False)
    )
