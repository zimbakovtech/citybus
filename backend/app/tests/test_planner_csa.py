"""Unit tests for the pure CSA planner on a small hand-built network.

Fixture network (stops 1..4, times in plain seconds, buffer 120 s):

    trip 10 (route 100):  1 --(100->200)--> 2 --(220->300)--> 3
    trip 20 (route 200):  2 --(500->600)--> 4
    trip 30 (route 200):  2 --(250->350)--> 4   (departs too soon to transfer)

Arriving at stop 2 at t=200, a transfer needs 200+120=320, so trip 30 (dep 250)
is not boardable and the correct journey to stop 4 uses trip 20, arriving 600.
"""

from app.services.csa import Connection, plan


def c(dep_stop, arr_stop, dep, arr, trip, seq=1, route=0) -> Connection:
    return Connection(
        dep_stop=dep_stop,
        arr_stop=arr_stop,
        dep_time=dep,
        arr_time=arr,
        trip_id=trip,
        dep_sequence=seq,
        route_id=route,
    )


FIXTURE = sorted(
    [
        c(1, 2, 100, 200, trip=10, seq=1, route=100),
        c(2, 3, 220, 300, trip=10, seq=2, route=100),
        c(2, 4, 250, 350, trip=30, seq=1, route=200),
        c(2, 4, 500, 600, trip=20, seq=1, route=200),
    ],
    key=lambda x: x.dep_time,
)

BUFFER = 120


def test_same_trip_needs_no_transfer_buffer() -> None:
    legs = plan(FIXTURE, origin=1, destination=3, depart_at=0, transfer_buffer=BUFFER)
    assert legs is not None
    assert len(legs) == 1, "riding through on trip 10 is a single leg"
    leg = legs[0]
    assert (leg.board_stop, leg.alight_stop) == (1, 3)
    assert (leg.board_time, leg.alight_time) == (100, 300)
    assert leg.num_stops == 2


def test_transfer_respects_buffer_and_finds_earliest_arrival() -> None:
    legs = plan(FIXTURE, origin=1, destination=4, depart_at=0, transfer_buffer=BUFFER)
    assert legs is not None
    assert len(legs) == 2, "one transfer expected"
    first, second = legs
    assert first.trip_id == 10 and second.trip_id == 20, "trip 30 departs before buffer allows"
    assert second.board_time - first.alight_time >= BUFFER
    assert second.alight_time == 600


def test_boarding_exactly_at_buffer_is_allowed() -> None:
    extra = sorted(
        FIXTURE + [c(2, 4, 320, 400, trip=40, seq=1, route=200)], key=lambda x: x.dep_time
    )
    legs = plan(extra, origin=1, destination=4, depart_at=0, transfer_buffer=BUFFER)
    assert legs is not None
    assert legs[-1].trip_id == 40, "arrival 200 + 120 s buffer == departure 320 is boardable"
    assert legs[-1].alight_time == 400


def test_no_buffer_when_boarding_at_the_origin() -> None:
    legs = plan(FIXTURE, origin=2, destination=4, depart_at=250, transfer_buffer=BUFFER)
    assert legs is not None
    assert legs[0].trip_id == 30, "waiting at the origin needs no transfer buffer"


def test_departure_time_is_respected() -> None:
    legs = plan(FIXTURE, origin=1, destination=3, depart_at=101, transfer_buffer=BUFFER)
    assert legs is None, "the only trip from stop 1 left at 100"


def test_unreachable_destination() -> None:
    assert plan(FIXTURE, origin=3, destination=1, depart_at=0, transfer_buffer=BUFFER) is None


def test_origin_equals_destination() -> None:
    assert plan(FIXTURE, origin=1, destination=1, depart_at=0, transfer_buffer=BUFFER) == []
