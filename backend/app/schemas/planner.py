from datetime import datetime
from typing import Annotated, Literal

from pydantic import BaseModel, Field

from app.schemas.route import RouteSummary
from app.schemas.stop import StopSummary


class PlanRideLeg(BaseModel):
    type: Literal["ride"] = "ride"
    route: RouteSummary
    trip_id: int
    board_stop: StopSummary
    board_time: datetime
    alight_stop: StopSummary
    alight_time: datetime
    num_stops: int  # stops traveled, excluding the boarding stop


class PlanTransferLeg(BaseModel):
    type: Literal["transfer"] = "transfer"
    at_stop: StopSummary
    seconds: int


PlanLeg = Annotated[PlanRideLeg | PlanTransferLeg, Field(discriminator="type")]


class PlanResponse(BaseModel):
    """A journey plan; found=False is the explicit 'no route found' result."""

    found: bool
    from_stop: StopSummary
    to_stop: StopSummary
    depart_at: datetime
    arrive_at: datetime | None
    duration_seconds: int | None
    transfers: int | None
    legs: list[PlanLeg]
