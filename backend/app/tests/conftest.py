"""Test fixtures.

The API tests run against the real database with the sample GTFS feed imported
(`make seed`). The seed feed is deterministic, so ids and schedule times are
stable and can be asserted exactly.
"""

from collections.abc import AsyncIterator

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


@pytest.fixture
async def client() -> AsyncIterator[AsyncClient]:
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as test_client:
        yield test_client
