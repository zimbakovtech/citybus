"""Connection Scan Algorithm (CSA) — earliest-arrival journey planning.

A *connection* is one hop of one trip between consecutive stops. CSA scans all
of a day's connections once, in departure-time order, relaxing each one — no
priority queue needed, which makes it simpler than Dijkstra/A* while still
being exact for earliest arrival. (Dijkstra on a time-expanded graph would work
too; CSA was chosen because the connection array falls directly out of the
stop_times table and the scan is easy to reason about.)

Plain earliest-arrival CSA can return journeys with pointless extra transfers
when several journeys arrive at the same time (e.g. riding one stop in the
wrong direction to board the same later bus earlier). To avoid that, stops are
labeled with the pair (arrival_time, trips_used) compared lexicographically:
arrival time first, then number of vehicles among equal arrivals.

This module is pure (no I/O): times are plain seconds since service midnight,
stops and trips are opaque ints. That makes it directly unit-testable on small
hand-built fixtures.
"""

from dataclasses import dataclass

INF = float("inf")


@dataclass(frozen=True, slots=True)
class Connection:
    """One hop of one trip between consecutive stops."""

    dep_stop: int
    arr_stop: int
    dep_time: int  # seconds since service midnight (may exceed 24h * 3600)
    arr_time: int
    trip_id: int
    dep_sequence: int  # stop_sequence of dep_stop within the trip
    route_id: int


@dataclass(frozen=True, slots=True)
class RideLeg:
    """A stretch of consecutive connections ridden on one trip."""

    trip_id: int
    route_id: int
    board_stop: int
    board_time: int
    alight_stop: int
    alight_time: int
    num_stops: int  # hops ridden (stops visited excluding the boarding stop)


@dataclass(slots=True)
class _StopLabel:
    arr_time: float
    trips_used: float
    alight_conn: Connection | None  # connection that achieved this label
    entry_conn: Connection | None  # where its trip was boarded


@dataclass(slots=True)
class _TripState:
    trips_used: int  # vehicles used including this trip
    entry_conn: Connection


def plan(
    connections: list[Connection],
    origin: int,
    destination: int,
    depart_at: int,
    transfer_buffer: int,
) -> list[RideLeg] | None:
    """Best journey from origin to destination: earliest arrival, and fewest
    vehicles among journeys with that arrival.

    connections must be sorted by dep_time. transfer_buffer is the minimum
    number of seconds needed to change vehicles at a stop; staying on the same
    trip (or boarding the first one at the origin) needs no buffer. Returns the
    ride legs of the journey, or None if the destination is unreachable.
    """
    labels: dict[int, _StopLabel] = {
        origin: _StopLabel(depart_at, 0, alight_conn=None, entry_conn=None)
    }
    boarded: dict[int, _TripState] = {}

    for c in connections:
        if c.dep_time < depart_at:
            continue
        # sorted scan: a connection departing after the destination's best
        # arrival cannot be part of any journey that matches it
        if destination in labels and c.dep_time > labels[destination].arr_time:
            break

        # option 1: board (or re-board) fresh at dep_stop, if reachable in time
        state = boarded.get(c.trip_id)
        at_dep = labels.get(c.dep_stop)
        if at_dep is not None:
            # changing vehicles costs the buffer; waiting at the origin does not
            buffer = 0 if at_dep.alight_conn is None else transfer_buffer
            if at_dep.arr_time + buffer <= c.dep_time:
                fresh_trips = int(at_dep.trips_used) + 1
                # a later boarding point with fewer preceding vehicles wins
                if state is None or fresh_trips < state.trips_used:
                    state = _TripState(fresh_trips, c)
                    boarded[c.trip_id] = state

        # option 2 is implicit: state is set from an earlier connection of the
        # same trip (already on board)
        if state is None:
            continue

        candidate = (c.arr_time, state.trips_used)
        current = labels.get(c.arr_stop)
        if current is None or candidate < (current.arr_time, current.trips_used):
            labels[c.arr_stop] = _StopLabel(
                c.arr_time, state.trips_used, alight_conn=c, entry_conn=state.entry_conn
            )

    label = labels.get(destination)
    if label is None or label.alight_conn is None:
        return None if destination != origin else []

    # walk backwards: each label stores the alighting connection and where its
    # trip was boarded
    legs: list[RideLeg] = []
    cursor = destination
    while cursor != origin:
        current = labels[cursor]
        last, entry = current.alight_conn, current.entry_conn
        assert last is not None and entry is not None
        legs.append(
            RideLeg(
                trip_id=last.trip_id,
                route_id=last.route_id,
                board_stop=entry.dep_stop,
                board_time=entry.dep_time,
                alight_stop=last.arr_stop,
                alight_time=last.arr_time,
                num_stops=last.dep_sequence + 1 - entry.dep_sequence,
            )
        )
        cursor = entry.dep_stop
    legs.reverse()
    return legs
