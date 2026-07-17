from pydantic import BaseModel

from app.schemas.route import RouteSummary
from app.schemas.stop import StopSummary


class TripStopTime(BaseModel):
    stop_sequence: int
    stop: StopSummary
    # HH:MM:SS since service midnight; may exceed 24:00:00 for after-midnight service
    arrival_time: str
    departure_time: str


class TripDetail(BaseModel):
    id: int
    gtfs_trip_id: str
    route: RouteSummary
    headsign: str | None
    direction_id: int | None
    stop_times: list[TripStopTime]
