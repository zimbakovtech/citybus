from datetime import datetime

from pydantic import BaseModel

from app.schemas.route import RouteSummary


class StopSummary(BaseModel):
    id: int
    name: str
    code: str | None
    lat: float
    lon: float


class StopWithDistance(StopSummary):
    distance_m: float


class StopDetail(StopSummary):
    description: str | None
    routes: list[RouteSummary]


class Departure(BaseModel):
    """One upcoming departure from a stop."""

    trip_id: int
    route: RouteSummary
    headsign: str | None
    departure_at: datetime
    stop_sequence: int
