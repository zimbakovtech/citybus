-- CityBus indexes.
--
-- Strategy:
--  * GiST on every geometry column — powers ST_DWithin radius filters and the
--    KNN distance operator (<->) used by /stops/nearby and live-vehicle maps.
--  * GIN + gin_trgm_ops on searchable text (stop and route names) — powers
--    fast fuzzy/substring ILIKE search.
--  * B-tree composites for the hot schedule lookups: departures at a stop
--    ordered by time, and a trip's stop_times in sequence order.
--  * A plain B-tree on every foreign key that is not already covered by a
--    composite, so joins and ON DELETE checks never table-scan.

CREATE INDEX idx_stops_geom              ON stops USING GIST (geom);
CREATE INDEX idx_stops_name_trgm         ON stops USING GIN (name gin_trgm_ops);
CREATE INDEX idx_routes_shortname_trgm   ON routes USING GIN (short_name gin_trgm_ops);
CREATE INDEX idx_routes_longname_trgm    ON routes USING GIN (long_name  gin_trgm_ops);
CREATE INDEX idx_routes_agency           ON routes (agency_id);
CREATE INDEX idx_trips_route             ON trips (route_id);
CREATE INDEX idx_trips_service           ON trips (service_id);
CREATE INDEX idx_trips_shape             ON trips (shape_id);
CREATE INDEX idx_stop_times_stop_dep     ON stop_times (stop_id, departure_time);
CREATE INDEX idx_stop_times_trip         ON stop_times (trip_id, stop_sequence);
CREATE INDEX idx_calendar_dates_service  ON calendar_dates (service_id, date);
CREATE INDEX idx_shape_points_shape      ON shape_points (shape_id, pt_sequence);
CREATE INDEX idx_vpos_geom               ON vehicle_positions USING GIST (geom);
CREATE INDEX idx_vpos_trip               ON vehicle_positions (trip_id);
CREATE INDEX idx_vpos_recorded_at        ON vehicle_positions (recorded_at DESC);
