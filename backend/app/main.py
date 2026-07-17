"""CityBus API application entry point."""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.v1.router import api_router
from app.core.exceptions import NotFoundError
from app.core.logging import configure_logging

configure_logging()

app = FastAPI(
    title="CityBus API",
    description=(
        "Public-transport API over a GTFS-modeled PostGIS database: stops, "
        "routes, schedules, a journey planner and simulated realtime vehicles."
    ),
    version="1.0.0",
)

# local development only: the Flutter app runs on a device/emulator origin
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(NotFoundError)
async def not_found_handler(request: Request, exc: NotFoundError) -> JSONResponse:
    return JSONResponse(status_code=404, content={"detail": str(exc)})


app.include_router(api_router)
