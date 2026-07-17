"""Journey planning use-case: resolve endpoints, load the day's connections,
run CSA and assemble the response."""

from datetime import datetime, timedelta

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.exceptions import NotFoundError
from app.models import Route, Stop
from app.repositories.connection_repository import ConnectionRepository
from app.repositories.service_repository import ServiceRepository
from app.repositories.stop_repository import StopRepository
from app.schemas.planner import PlanResponse, PlanRideLeg, PlanTransferLeg
from app.schemas.route import RouteSummary
from app.schemas.stop import StopSummary
from app.services import csa

DAY_S = 24 * 3600


class PlannerService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.stops = StopRepository(session)
        self.services = ServiceRepository(session)
        self.connections = ConnectionRepository(session)

    async def resolve_stop(self, stop_id: int | None, lat: float | None, lon: float | None) -> Stop:
        """A plan endpoint is either an explicit stop id or a coordinate pair
        snapped to the nearest stop."""
        if stop_id is None:
            stop_id = await self.stops.nearest_stop_id(lat, lon)  # type: ignore[arg-type]
        stop = await self.stops.get(stop_id) if stop_id is not None else None
        if stop is None:
            raise NotFoundError("stop", stop_id)
        return stop

    async def plan(self, origin: Stop, destination: Stop, depart_at: datetime) -> PlanResponse:
        """Earliest-arrival journey, allowing transfers.

        Connections come from two service days expressed in today's clock:
        today's services as-is (their own past-24:00 times included), and
        yesterday's services shifted by -24h so a night bus still on the road
        after midnight is boardable this morning.
        """
        depart_s = int(
            timedelta(
                hours=depart_at.hour, minutes=depart_at.minute, seconds=depart_at.second
            ).total_seconds()
        )
        today = depart_at.date()

        today_services = await self.services.active_service_ids(today)
        yesterday_services = await self.services.active_service_ids(today - timedelta(days=1))
        connections = sorted(
            await self.connections.connections_for_services(yesterday_services, -DAY_S)
            + await self.connections.connections_for_services(today_services),
            key=lambda c: c.dep_time,
        )

        legs = csa.plan(
            connections,
            origin.id,
            destination.id,
            depart_s,
            settings.transfer_buffer_seconds,
        )

        midnight = datetime.combine(today, datetime.min.time())
        origin_summary = _stop_summary(origin)
        destination_summary = _stop_summary(destination)

        if legs is None:
            return PlanResponse(
                found=False,
                from_stop=origin_summary,
                to_stop=destination_summary,
                depart_at=depart_at,
                arrive_at=None,
                duration_seconds=None,
                transfers=None,
                legs=[],
            )

        stop_ids = {leg.board_stop for leg in legs} | {leg.alight_stop for leg in legs}
        route_ids = {leg.route_id for leg in legs}
        stops = {s.id: s for s in [await self.stops.get(sid) for sid in stop_ids] if s}
        routes = {r.id: r for r in [await self.session.get(Route, rid) for rid in route_ids] if r}

        plan_legs: list[PlanRideLeg | PlanTransferLeg] = []
        for i, leg in enumerate(legs):
            if i > 0:
                previous = legs[i - 1]
                plan_legs.append(
                    PlanTransferLeg(
                        at_stop=_stop_summary(stops[leg.board_stop]),
                        seconds=leg.board_time - previous.alight_time,
                    )
                )
            plan_legs.append(
                PlanRideLeg(
                    route=RouteSummary.model_validate(routes[leg.route_id], from_attributes=True),
                    trip_id=leg.trip_id,
                    board_stop=_stop_summary(stops[leg.board_stop]),
                    board_time=midnight + timedelta(seconds=leg.board_time),
                    alight_stop=_stop_summary(stops[leg.alight_stop]),
                    alight_time=midnight + timedelta(seconds=leg.alight_time),
                    num_stops=leg.num_stops,
                )
            )

        arrive_at = midnight + timedelta(seconds=legs[-1].alight_time)
        return PlanResponse(
            found=True,
            from_stop=origin_summary,
            to_stop=destination_summary,
            depart_at=depart_at,
            arrive_at=arrive_at,
            duration_seconds=int((arrive_at - depart_at).total_seconds()),
            transfers=len(legs) - 1,
            legs=plan_legs,
        )


def _stop_summary(stop: Stop) -> StopSummary:
    return StopSummary.model_validate(stop, from_attributes=True)
