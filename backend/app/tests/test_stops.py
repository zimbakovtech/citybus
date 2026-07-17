"""Stop endpoints: search, nearby, detail, departures (incl. after-midnight
and holiday exceptions).

Fixed ids from the deterministic seed feed:
  stop 1 = Transporten Centar, stop 2 = Plostad Makedonija (interchange)
  route 1 = line "2" (runs the after-midnight night trip)
Dates: 2026-05-04 is a Monday; 2026-09-08 is a Tuesday holiday where the
WEEKDAY service is removed and the WEEKEND service added via calendar_dates.
"""

from httpx import AsyncClient

PLOSTAD = 2  # Plostad Makedonija
PLOSTAD_LAT, PLOSTAD_LON = 41.9947, 21.4314


async def test_health(client: AsyncClient) -> None:
    response = await client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


async def test_stop_search(client: AsyncClient) -> None:
    response = await client.get("/api/v1/stops", params={"search": "plostad"})
    assert response.status_code == 200
    body = response.json()
    assert body["total"] >= 1
    assert any(item["id"] == PLOSTAD for item in body["items"])
    assert body["items"][0]["name"] == "Plostad Makedonija"


async def test_stop_search_pagination(client: AsyncClient) -> None:
    response = await client.get("/api/v1/stops", params={"limit": 5, "offset": 0})
    body = response.json()
    assert body["total"] == 30
    assert len(body["items"]) == 5


async def test_nearby_stops(client: AsyncClient) -> None:
    response = await client.get(
        "/api/v1/stops/nearby",
        params={"lat": PLOSTAD_LAT, "lon": PLOSTAD_LON, "radius_m": 400},
    )
    assert response.status_code == 200
    stops = response.json()
    assert stops, "expected at least the square itself within 400 m"
    assert stops[0]["id"] == PLOSTAD
    assert stops[0]["distance_m"] < 20
    distances = [s["distance_m"] for s in stops]
    assert distances == sorted(distances)


async def test_stop_detail_lists_serving_routes(client: AsyncClient) -> None:
    response = await client.get(f"/api/v1/stops/{PLOSTAD}")
    assert response.status_code == 200
    body = response.json()
    assert body["name"] == "Plostad Makedonija"
    short_names = {route["short_name"] for route in body["routes"]}
    # the square is the interchange of lines 2, 5 and 15
    assert {"2", "5", "15"} <= short_names


async def test_stop_not_found(client: AsyncClient) -> None:
    response = await client.get("/api/v1/stops/99999")
    assert response.status_code == 404
    assert "detail" in response.json()


async def test_departures_weekday_morning(client: AsyncClient) -> None:
    response = await client.get(
        f"/api/v1/stops/{PLOSTAD}/departures",
        params={"at": "2026-05-04T08:00:00", "window_min": 30},
    )
    assert response.status_code == 200
    departures = response.json()
    assert departures, "expected weekday morning departures at the interchange"
    times = [d["departure_at"] for d in departures]
    assert times == sorted(times)
    for departure in departures:
        assert "2026-05-04T08:0" in departure["departure_at"] or (
            "2026-05-04T08:" in departure["departure_at"]
        )
        assert departure["route"]["short_name"] in {"2", "5", "15"}


async def test_departures_after_midnight(client: AsyncClient) -> None:
    """Monday's night trip (dep 23:45, times past 24:00:00) must appear in a
    window queried shortly after midnight on Tuesday."""
    response = await client.get(
        f"/api/v1/stops/{PLOSTAD}/departures",
        params={"at": "2026-05-05T00:00:00", "window_min": 30},
    )
    assert response.status_code == 200
    departures = response.json()
    assert departures, "expected the after-midnight night trip"
    assert all(d["route"]["short_name"] == "2" for d in departures)
    assert all(d["departure_at"].startswith("2026-05-05T00:") for d in departures)


async def test_departures_holiday_uses_weekend_service(client: AsyncClient) -> None:
    """2026-09-08 is a Tuesday, but calendar_dates removes WEEKDAY and adds
    WEEKEND service. Weekend trips start at 07:00, so 06:30 shows nothing,
    while a normal Tuesday does have departures then."""
    holiday = await client.get(
        f"/api/v1/stops/{PLOSTAD}/departures",
        params={"at": "2026-09-08T06:30:00", "window_min": 25},
    )
    normal_tuesday = await client.get(
        f"/api/v1/stops/{PLOSTAD}/departures",
        params={"at": "2026-09-15T06:30:00", "window_min": 25},
    )
    assert holiday.json() == []
    assert normal_tuesday.json() != []
