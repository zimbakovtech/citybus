"""Trip detail endpoint."""

from httpx import AsyncClient


async def test_trip_detail_with_ordered_stop_times(client: AsyncClient) -> None:
    trips = (
        await client.get("/api/v1/routes/1/trips", params={"service_date": "2026-05-04"})
    ).json()
    trip_id = trips[0]["id"]

    response = await client.get(f"/api/v1/trips/{trip_id}")
    assert response.status_code == 200
    body = response.json()
    assert body["route"]["short_name"] == "2"
    stop_times = body["stop_times"]
    assert len(stop_times) == 13
    sequences = [st["stop_sequence"] for st in stop_times]
    assert sequences == sorted(sequences)
    assert all(st["departure_time"] >= st["arrival_time"] for st in stop_times)


async def test_trip_not_found(client: AsyncClient) -> None:
    response = await client.get("/api/v1/trips/999999")
    assert response.status_code == 404
