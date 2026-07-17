# Database design

> Stub — completed in the final docs phase.

Schema lives in `database/sql/`. Key decisions: surrogate keys with GTFS natural
keys preserved, a normalized `services` table, `interval` for after-midnight
times, PostGIS geometries with GiST indexes, trigram indexes for text search.
