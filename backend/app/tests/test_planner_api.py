"""Planner endpoint tests on the seed network.

Known transfer case: stop 6 (Gradski Park) is served only by line 15; stop 20
(Kisela Voda) only by lines 5 and 24. Line 15 meets line 5 at the Plostad
Makedonija interchange (stop 2), so the fastest journey is 15 -> transfer -> 5.
"""

from httpx import AsyncClient

GRADSKI_PARK = 6
KISELA_VODA = 20


async def test_plan_with_one_transfer(client: AsyncClient) -> None:
    response = await client.get(
        "/api/v1/planner",
        params={
            "from_stop_id": GRADSKI_PARK,
            "to_stop_id": KISELA_VODA,
            "depart_at": "2026-05-04T08:00:00",
        },
    )
    assert response.status_code == 200
    body = response.json()
    assert body["found"] is True
    assert body["transfers"] == 1
    assert body["arrive_at"] > body["depart_at"]

    rides = [leg for leg in body["legs"] if leg["type"] == "ride"]
    transfers = [leg for leg in body["legs"] if leg["type"] == "transfer"]
    assert len(rides) == 2 and len(transfers) == 1
    assert rides[0]["route"]["short_name"] == "15"
    assert rides[1]["route"]["short_name"] == "5"
    assert transfers[0]["at_stop"]["id"] == 2, "transfer at Plostad Makedonija"
    assert transfers[0]["seconds"] >= 120
    assert rides[0]["board_time"] >= body["depart_at"]
    assert rides[1]["board_time"] >= rides[0]["alight_time"]
    assert body["arrive_at"] == rides[1]["alight_time"]
    assert body["duration_seconds"] > 0


async def test_plan_direct_journey_has_no_transfers(client: AsyncClient) -> None:
    # stops 10 -> 15 are the two termini of line 2
    response = await client.get(
        "/api/v1/planner",
        params={"from_stop_id": 10, "to_stop_id": 15, "depart_at": "2026-05-04T08:00:00"},
    )
    body = response.json()
    assert body["found"] is True
    assert body["transfers"] == 0
    assert len(body["legs"]) == 1
    assert body["legs"][0]["route"]["short_name"] == "2"
    assert body["legs"][0]["num_stops"] == 12


async def test_plan_by_coordinates_snaps_to_nearest_stops(client: AsyncClient) -> None:
    response = await client.get(
        "/api/v1/planner",
        params={
            "from_lat": 42.0061,  # ~10 m from Gradski Park
            "from_lon": 21.4189,
            "to_lat": 41.9699,  # ~10 m from Kisela Voda
            "to_lon": 21.4406,
            "depart_at": "2026-05-04T08:00:00",
        },
    )
    body = response.json()
    assert body["from_stop"]["id"] == GRADSKI_PARK
    assert body["to_stop"]["id"] == KISELA_VODA
    assert body["found"] is True


async def test_plan_no_service_late_night_returns_not_found_result(client: AsyncClient) -> None:
    """At 23:50 the last line-2 departure of the day (the 23:45 night trip) is
    gone and tomorrow's schedule is out of scope, so the planner must answer
    found=false, not an error."""
    response = await client.get(
        "/api/v1/planner",
        params={"from_stop_id": 10, "to_stop_id": 15, "depart_at": "2026-05-05T23:50:00"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["found"] is False
    assert body["legs"] == []
    assert body["arrive_at"] is None


async def test_plan_after_midnight_uses_yesterdays_night_trip(client: AsyncClient) -> None:
    """Just after midnight the line-2 night trip (departed 23:45 yesterday) is
    still running and must be usable."""
    response = await client.get(
        "/api/v1/planner",
        params={"from_stop_id": 2, "to_stop_id": 15, "depart_at": "2026-05-05T00:00:00"},
    )
    body = response.json()
    assert body["found"] is True
    assert body["transfers"] == 0
    assert body["arrive_at"].startswith("2026-05-05T00:")


async def test_plan_missing_endpoint_params(client: AsyncClient) -> None:
    response = await client.get(
        "/api/v1/planner", params={"depart_at": "2026-05-04T08:00:00", "to_stop_id": 15}
    )
    assert response.status_code == 422
