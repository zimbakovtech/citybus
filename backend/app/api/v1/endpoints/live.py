from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.schemas.live import LiveVehicle
from app.services.realtime_service import RealtimeService

router = APIRouter(prefix="/live", tags=["live"])


def get_service(session: AsyncSession = Depends(get_session)) -> RealtimeService:
    return RealtimeService(session)


@router.get(
    "/vehicles",
    summary="Live vehicle snapshot",
    description=(
        "Latest simulated position per active vehicle (seen within the last "
        "minute). For continuous updates use the /ws/realtime WebSocket."
    ),
    response_model=list[LiveVehicle],
)
async def live_vehicles(service: RealtimeService = Depends(get_service)) -> list[LiveVehicle]:
    snapshot = await service.snapshot()
    return [LiveVehicle(**vehicle) for vehicle in snapshot["vehicles"]]
