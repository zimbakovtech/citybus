from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.schemas.common import ErrorResponse
from app.schemas.trip import TripDetail
from app.services.trip_service import TripService

router = APIRouter(prefix="/trips", tags=["trips"])


def get_service(session: AsyncSession = Depends(get_session)) -> TripService:
    return TripService(session)


@router.get(
    "/{trip_id}",
    summary="Trip detail",
    description="A trip with its ordered stop_times (times may exceed 24:00:00).",
    response_model=TripDetail,
    responses={404: {"model": ErrorResponse}},
)
async def trip_detail(trip_id: int, service: TripService = Depends(get_service)) -> TripDetail:
    return await service.detail(trip_id)
