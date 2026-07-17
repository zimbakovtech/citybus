"""Helpers for GTFS times (intervals since service midnight, may exceed 24h)."""

from datetime import timedelta


def format_interval(value: timedelta) -> str:
    """timedelta -> GTFS-style HH:MM:SS; hours may exceed 24 (e.g. '24:29:00')."""
    total = int(value.total_seconds())
    h, rem = divmod(total, 3600)
    m, s = divmod(rem, 60)
    return f"{h:02d}:{m:02d}:{s:02d}"
