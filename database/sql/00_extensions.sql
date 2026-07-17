-- Extensions required by the CityBus schema.
--
-- postgis : geometry types (points for stops/vehicles, linestrings for route
--           shapes), spatial indexes (GiST) and functions (ST_DWithin, KNN, ...)
-- pg_trgm : trigram similarity, used to index stop/route names for fast
--           fuzzy/substring text search (GIN + gin_trgm_ops)

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
