from sqlalchemy import BigInteger, ForeignKey, Identity, Integer, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class ShapePoint(Base):
    """Ordered vertex of a shape, as delivered in the feed (GTFS shapes.txt rows)."""

    __tablename__ = "shape_points"
    __table_args__ = (UniqueConstraint("shape_id", "pt_sequence"),)

    id: Mapped[int] = mapped_column(BigInteger, Identity(always=True), primary_key=True)
    shape_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("shapes.id", ondelete="CASCADE"))
    pt_sequence: Mapped[int] = mapped_column(Integer)
    lat: Mapped[float]
    lon: Mapped[float]
    dist_traveled: Mapped[float | None]
