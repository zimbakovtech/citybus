"""Pure unit tests for GTFS time/date handling (no database needed)."""

from datetime import date, timedelta

import pytest

from app.core.gtfs_time import format_interval
from app.services.gtfs_import_service import parse_gtfs_date, parse_gtfs_time


def test_parse_regular_time() -> None:
    assert parse_gtfs_time("08:15:30") == timedelta(hours=8, minutes=15, seconds=30)


def test_parse_after_midnight_time_is_not_clamped() -> None:
    assert parse_gtfs_time("25:30:00") == timedelta(hours=25, minutes=30)
    assert parse_gtfs_time("24:00:00") == timedelta(hours=24)


def test_format_interval_pads_and_keeps_hours_past_24() -> None:
    assert format_interval(timedelta(hours=6, minutes=5)) == "06:05:00"
    assert format_interval(timedelta(hours=24, minutes=29)) == "24:29:00"


@pytest.mark.parametrize(
    "value",
    ["00:00:00", "06:00:00", "23:59:59", "24:29:00", "25:30:15"],
)
def test_parse_format_roundtrip(value: str) -> None:
    assert format_interval(parse_gtfs_time(value)) == value


def test_parse_gtfs_date() -> None:
    assert parse_gtfs_date("20260908") == date(2026, 9, 8)
