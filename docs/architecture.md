# Architecture

> Stub — completed in the final docs phase.

Components: PostgreSQL+PostGIS (Docker) ← FastAPI backend (REST + WebSocket) ← Flutter app.

Data flow: GTFS feed → import script → Postgres → SQL queries (spatial + schedule) → JSON/GeoJSON → mobile app.
