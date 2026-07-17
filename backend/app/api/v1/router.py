from fastapi import APIRouter

from app.api.v1.endpoints import routes, stops, trips

api_router = APIRouter(prefix="/api/v1")


@api_router.get("/health", tags=["health"], summary="Liveness check")
async def health() -> dict[str, str]:
    return {"status": "ok"}


api_router.include_router(stops.router)
api_router.include_router(routes.router)
api_router.include_router(trips.router)
