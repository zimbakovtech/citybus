from datetime import datetime

from pydantic import BaseModel


class LiveVehicle(BaseModel):
    """Latest known state of one simulated vehicle."""

    vehicle_id: str
    trip_id: int | None
    route_short_name: str | None
    lat: float
    lon: float
    delay_seconds: int
    current_stop_id: int | None
    recorded_at: datetime
