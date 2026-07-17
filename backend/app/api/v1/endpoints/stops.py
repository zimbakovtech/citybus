from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.schemas.common import ErrorResponse, Page
from app.schemas.stop import Departure, StopDetail, StopSummary, StopWithDistance
from app.services.stop_service import StopService

router = APIRouter(prefix="/stops", tags=["stops"])


def get_service(session: AsyncSession = Depends(get_session)) -> StopService:
    return StopService(session)


@router.get("", summary="Search stops", response_model=Page[StopSummary])
async def list_stops(
    search: str | None = Query(None, description="Fuzzy match on stop name (trigram index)"),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    service: StopService = Depends(get_service),
) -> Page[StopSummary]:
    return await service.search(search, limit, offset)


@router.get(
    "/nearby",
    summary="Stops near a point",
    description="Stops within radius_m of (lat, lon), nearest first, with distance in meters.",
    response_model=list[StopWithDistance],
)
async def nearby_stops(
    lat: float = Query(..., ge=-90, le=90),
    lon: float = Query(..., ge=-180, le=180),
    radius_m: float = Query(500, gt=0, le=10000),
    limit: int = Query(10, ge=1, le=50),
    service: StopService = Depends(get_service),
) -> list[StopWithDistance]:
    return await service.nearby(lat, lon, radius_m, limit)


@router.get(
    "/{stop_id}",
    summary="Stop detail",
    description="Stop attributes plus the distinct routes serving it.",
    response_model=StopDetail,
    responses={404: {"model": ErrorResponse}},
)
async def stop_detail(stop_id: int, service: StopService = Depends(get_service)) -> StopDetail:
    return await service.detail(stop_id)


@router.get(
    "/{stop_id}/departures",
    summary="Upcoming departures at a stop",
    description=(
        "Scheduled departures within the window, resolving which services are "
        "active on the date (calendar + calendar_dates) and handling "
        "after-midnight trips (times past 24:00:00)."
    ),
    response_model=list[Departure],
    responses={404: {"model": ErrorResponse}},
)
async def stop_departures(
    stop_id: int,
    at: datetime = Query(..., description="Start of the window (ISO datetime, local)"),
    window_min: int = Query(60, ge=1, le=24 * 60),
    service: StopService = Depends(get_service),
) -> list[Departure]:
    return await service.departures(stop_id, at, window_min)
