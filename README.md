# CityBus — City Bus Transit System

Final project for the Databases course. A public-transport system built around a
PostgreSQL + PostGIS database storing a GTFS-modeled bus network, with a FastAPI
backend and a Flutter mobile app.

> **Status:** work in progress — see `docs/` for architecture and database design.

## Components

- `database/` — canonical SQL schema (PostGIS), indexes, and a synthetic GTFS seed feed
- `backend/` — FastAPI + SQLAlchemy (async) REST/WebSocket API, GTFS importer, route planner
- `mobile/` — Flutter app (stops, routes, journey planner, live vehicle tracking)

## Quick start

```bash
make up        # start postgres+postgis via docker compose
make seed      # run migrations + import the sample GTFS feed
make api       # start the FastAPI dev server (http://localhost:8000/docs)
```

Full instructions, architecture, and the data-model discussion will be completed
in the final docs phase.
