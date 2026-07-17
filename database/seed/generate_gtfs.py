#!/usr/bin/env python3
"""Deterministic generator for the synthetic CityBus GTFS feed (Skopje).

Regenerates the .txt files in database/seed/gtfs/. The generated files are
committed so the project runs fully offline — this script only exists to make
the feed reproducible and easy to tweak.

Usage: python3 database/seed/generate_gtfs.py
"""

from __future__ import annotations

import csv
import math
from pathlib import Path

OUT_DIR = Path(__file__).parent / "gtfs"

# --------------------------------------------------------------------------
# Network definition (Skopje, North Macedonia — approximate real locations)
# --------------------------------------------------------------------------

AGENCY = {
    "agency_id": "CITYBUS",
    "agency_name": "CityBus Skopje",
    "agency_url": "https://citybus.example",
    "agency_timezone": "Europe/Skopje",
    "agency_lang": "mk",
    "agency_phone": "+389 2 000 000",
}

# stop_id, name, lat, lon
STOPS = [
    ("S01", "Transporten Centar", 41.9857, 21.4448),
    ("S02", "Plostad Makedonija", 41.9947, 21.4314),
    ("S03", "Bit Pazar", 42.0009, 21.4390),
    ("S04", "Univerzitet", 42.0043, 21.4460),
    ("S05", "Sobranie", 41.9938, 21.4353),
    ("S06", "Gradski Park", 42.0060, 21.4188),
    ("S07", "Karpos 2", 42.0043, 21.4046),
    ("S08", "Karpos 4", 42.0022, 21.3934),
    ("S09", "Porta Vlae", 42.0043, 21.3776),
    ("S10", "Gjorche Petrov", 42.0089, 21.3565),
    ("S11", "Debar Maalo", 41.9990, 21.4223),
    ("S12", "Rekord", 42.0009, 21.4118),
    ("S13", "Aerodrom Centar", 41.9793, 21.4626),
    ("S14", "Jane Sandanski", 41.9769, 21.4718),
    ("S15", "Novo Lisice", 41.9723, 21.4841),
    ("S16", "Avtokomanda", 42.0102, 21.4508),
    ("S17", "Zelezara", 42.0193, 21.4577),
    ("S18", "Butel", 42.0329, 21.4487),
    ("S19", "Chair", 42.0119, 21.4382),
    ("S20", "Kisela Voda", 41.9698, 21.4405),
    ("S21", "Crniche", 41.9770, 21.4331),
    ("S22", "Pripor", 41.9736, 21.4265),
    ("S23", "Zeleznichka", 41.9921, 21.4405),
    ("S24", "Mavrovka", 41.9995, 21.4345),
    ("S25", "Klinichki Centar", 41.9878, 21.4189),
    ("S26", "Medicinski Fakultet", 41.9902, 21.4237),
    ("S27", "Bunjakovec", 41.9942, 21.4243),
    ("S28", "Sudska Palata", 41.9891, 21.4290),
    ("S29", "Lisice", 41.9673, 21.4696),
    ("S30", "Drachevo", 41.9469, 21.4972),
]
STOP_BY_ID = {s[0]: s for s in STOPS}

# route_id, short_name, long_name, color, ordered stop_ids (direction 0),
# weekday headway (min), weekend headway (min)
ROUTES = [
    (
        "R2", "2", "Gjorche Petrov - Novo Lisice", "D32F2F",
        ["S10", "S09", "S08", "S07", "S12", "S11", "S27", "S02", "S23", "S01", "S13", "S14", "S15"],
        20, 30,
    ),
    (
        "R5", "5", "Butel - Kisela Voda", "1976D2",
        ["S18", "S17", "S16", "S19", "S03", "S24", "S02", "S21", "S22", "S20"],
        20, 30,
    ),
    (
        "R15", "15", "Gradski Park - Avtokomanda", "388E3C",
        ["S06", "S11", "S27", "S02", "S05", "S04", "S16"],
        30, 40,
    ),
    (
        "R22", "22", "Klinichki Centar - Zelezara", "F57C00",
        ["S25", "S26", "S28", "S23", "S01", "S05", "S04", "S17"],
        30, 40,
    ),
    (
        "R24", "24", "Kisela Voda - Drachevo", "7B1FA2",
        ["S20", "S21", "S23", "S01", "S13", "S29", "S30"],
        30, 40,
    ),
]

SERVICES = {
    # service_id: (mon..sun flags, start, end)
    "WEEKDAY": ([1, 1, 1, 1, 1, 0, 0], "20260101", "20261231"),
    "WEEKEND": ([0, 0, 0, 0, 0, 1, 1], "20260101", "20261231"),
}

# 2026-09-08 (Independence Day, a Tuesday): weekday service replaced by the
# weekend timetable — exercises both exception_type values.
CALENDAR_DATES = [
    ("WEEKDAY", "20260908", 2),  # removed
    ("WEEKEND", "20260908", 1),  # added
]

# Weekday span 06:00-23:00, weekend 07:00-22:00 (departures from each terminus).
WEEKDAY_SPAN = (6 * 3600, 23 * 3600)
WEEKEND_SPAN = (7 * 3600, 22 * 3600)

# Route 2 additionally runs one late weekday trip per direction departing at
# 23:45 so its stop_times cross 24:00:00 (exercises the interval modeling).
NIGHT_TRIP_ROUTE = "R2"
NIGHT_TRIP_DEP = 23 * 3600 + 45 * 60

BUS_SPEED_MPS = 20 * 1000 / 3600  # 20 km/h average including traffic
DWELL_S = 30  # added per inter-stop hop, rounded into the travel time


def haversine_m(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371000.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp, dl = math.radians(lat2 - lat1), math.radians(lon2 - lon1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


def hop_seconds(stop_a: str, stop_b: str) -> int:
    """Travel time between consecutive stops, rounded up to 30s."""
    a, b = STOP_BY_ID[stop_a], STOP_BY_ID[stop_b]
    dist = haversine_m(a[2], a[3], b[2], b[3])
    secs = dist / BUS_SPEED_MPS + DWELL_S
    return int(math.ceil(secs / 30) * 30)


def fmt_time(total_s: int) -> str:
    """GTFS HH:MM:SS; hours may exceed 24 for after-midnight service."""
    h, rem = divmod(total_s, 3600)
    m, s = divmod(rem, 60)
    return f"{h:02d}:{m:02d}:{s:02d}"


def shape_points_for(stop_ids: list[str]) -> list[tuple[float, float]]:
    """Stop coordinates plus offset midpoints, so routes draw as gentle curves
    rather than straight stop-to-stop segments."""
    pts: list[tuple[float, float]] = []
    for i, sid in enumerate(stop_ids):
        _, _, lat, lon = STOP_BY_ID[sid]
        pts.append((lat, lon))
        if i < len(stop_ids) - 1:
            _, _, nlat, nlon = STOP_BY_ID[stop_ids[i + 1]]
            mid_lat, mid_lon = (lat + nlat) / 2, (lon + nlon) / 2
            # perpendicular-ish offset, alternating side, ~50 m
            off = 0.0005 if i % 2 == 0 else -0.0005
            pts.append((mid_lat + off, mid_lon - off))
    return pts


def write_csv(name: str, header: list[str], rows: list[list]) -> None:
    path = OUT_DIR / name
    with path.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    print(f"  {name}: {len(rows)} rows")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    write_csv(
        "agency.txt",
        list(AGENCY.keys()),
        [list(AGENCY.values())],
    )

    write_csv(
        "stops.txt",
        ["stop_id", "stop_code", "stop_name", "stop_desc", "stop_lat", "stop_lon", "location_type", "parent_station"],
        [[sid, sid.replace("S", "C"), name, "", lat, lon, 0, ""] for sid, name, lat, lon in STOPS],
    )

    write_csv(
        "routes.txt",
        ["route_id", "agency_id", "route_short_name", "route_long_name", "route_type", "route_color", "route_text_color"],
        [[rid, AGENCY["agency_id"], short, long_, 3, color, "FFFFFF"] for rid, short, long_, color, *_ in ROUTES],
    )

    write_csv(
        "calendar.txt",
        ["service_id", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday", "start_date", "end_date"],
        [[sid, *flags, start, end] for sid, (flags, start, end) in SERVICES.items()],
    )

    write_csv(
        "calendar_dates.txt",
        ["service_id", "date", "exception_type"],
        [list(row) for row in CALENDAR_DATES],
    )

    # shapes: one per route+direction (direction 1 is the reversed path)
    shape_rows: list[list] = []
    shape_ids: dict[tuple[str, int], str] = {}
    for rid, _short, _long, _color, stop_ids, _wd, _we in ROUTES:
        for direction in (0, 1):
            ids = stop_ids if direction == 0 else list(reversed(stop_ids))
            shape_id = f"SHP-{rid}-D{direction}"
            shape_ids[(rid, direction)] = shape_id
            dist = 0.0
            prev: tuple[float, float] | None = None
            for seq, (lat, lon) in enumerate(shape_points_for(ids), start=1):
                if prev is not None:
                    dist += haversine_m(prev[0], prev[1], lat, lon)
                prev = (lat, lon)
                shape_rows.append([shape_id, round(lat, 6), round(lon, 6), seq, round(dist, 1)])
    write_csv(
        "shapes.txt",
        ["shape_id", "shape_pt_lat", "shape_pt_lon", "shape_pt_sequence", "shape_dist_traveled"],
        shape_rows,
    )

    trip_rows: list[list] = []
    stop_time_rows: list[list] = []

    def add_trip(rid: str, stop_ids: list[str], direction: int, service_id: str, dep_s: int, tag: str) -> None:
        headsign = STOP_BY_ID[stop_ids[-1]][1]
        service_tag = {"WEEKDAY": "WD", "WEEKEND": "WE"}[service_id]
        trip_id = f"{rid}-D{direction}-{service_tag}-{tag}"
        trip_rows.append([rid, service_id, trip_id, headsign, direction, "", shape_ids[(rid, direction)]])
        t = dep_s
        dist = 0.0
        for seq, sid in enumerate(stop_ids, start=1):
            if seq > 1:
                prev_sid = stop_ids[seq - 2]
                t += hop_seconds(prev_sid, sid)
                a, b = STOP_BY_ID[prev_sid], STOP_BY_ID[sid]
                dist += haversine_m(a[2], a[3], b[2], b[3])
            stop_time_rows.append(
                [trip_id, fmt_time(t), fmt_time(t), sid, seq, "", 0, 0, round(dist, 1)]
            )

    for rid, _short, _long, _color, stop_ids, wd_headway, we_headway in ROUTES:
        for service_id, (span, headway) in {
            "WEEKDAY": (WEEKDAY_SPAN, wd_headway),
            "WEEKEND": (WEEKEND_SPAN, we_headway),
        }.items():
            for direction in (0, 1):
                ids = stop_ids if direction == 0 else list(reversed(stop_ids))
                dep = span[0]
                while dep <= span[1]:
                    add_trip(rid, ids, direction, service_id, dep, fmt_time(dep)[:5].replace(":", ""))
                    dep += headway * 60

    # after-midnight trips (route 2, weekday, both directions)
    for direction in (0, 1):
        stop_ids = ROUTES[0][4]
        ids = stop_ids if direction == 0 else list(reversed(stop_ids))
        add_trip(NIGHT_TRIP_ROUTE, ids, direction, "WEEKDAY", NIGHT_TRIP_DEP, "night")

    write_csv(
        "trips.txt",
        ["route_id", "service_id", "trip_id", "trip_headsign", "direction_id", "block_id", "shape_id"],
        trip_rows,
    )
    write_csv(
        "stop_times.txt",
        ["trip_id", "arrival_time", "departure_time", "stop_id", "stop_sequence", "stop_headsign", "pickup_type", "drop_off_type", "shape_dist_traveled"],
        stop_time_rows,
    )

    max_time = max(r[2] for r in stop_time_rows)
    print(f"done. latest departure_time in feed: {max_time}")


if __name__ == "__main__":
    main()
