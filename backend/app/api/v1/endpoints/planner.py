from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.schemas.common import ErrorResponse
from app.schemas.planner import PlanResponse
from app.services.planner_service import PlannerService

router = APIRouter(prefix="/planner", tags=["planner"])


def get_service(session: AsyncSession = Depends(get_session)) -> PlannerService:
    return PlannerService(session)


@router.get(
    "",
    summary="Plan a journey",
    description=(
        "Earliest-arrival journey between two stops (Connection Scan Algorithm, "
        "with transfers). Each endpoint is given either as a stop id or as a "
        "lat/lon pair snapped to the nearest stop. found=false means no journey "
        "exists on that date."
    ),
    response_model=PlanResponse,
    responses={404: {"model": ErrorResponse}},
)
async def plan_journey(
    depart_at: datetime = Query(..., description="Departure datetime (ISO, local)"),
    from_stop_id: int | None = Query(None),
    to_stop_id: int | None = Query(None),
    from_lat: float | None = Query(None, ge=-90, le=90),
    from_lon: float | None = Query(None, ge=-180, le=180),
    to_lat: float | None = Query(None, ge=-90, le=90),
    to_lon: float | None = Query(None, ge=-180, le=180),
    service: PlannerService = Depends(get_service),
) -> PlanResponse:
    if from_stop_id is None and (from_lat is None or from_lon is None):
        raise HTTPException(422, "provide from_stop_id or from_lat + from_lon")
    if to_stop_id is None and (to_lat is None or to_lon is None):
        raise HTTPException(422, "provide to_stop_id or to_lat + to_lon")

    origin = await service.resolve_stop(from_stop_id, from_lat, from_lon)
    destination = await service.resolve_stop(to_stop_id, to_lat, to_lon)
    return await service.plan(origin, destination, depart_at)
