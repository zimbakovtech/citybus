from pydantic import BaseModel


class RouteSummary(BaseModel):
    id: int
    short_name: str | None
    long_name: str | None
    color: str | None


class RouteDetail(RouteSummary):
    gtfs_route_id: str
    route_type: int
    text_color: str | None
    agency_name: str


class ShapeGeoJson(BaseModel):
    """GeoJSON LineString geometry of a route's path (WGS84, [lon, lat] pairs)."""

    type: str
    coordinates: list[list[float]]


class TripSummary(BaseModel):
    id: int
    headsign: str | None
    direction_id: int | None
    starts_at: str  # first departure, HH:MM:SS since service midnight (may exceed 24)
    ends_at: str  # last arrival
