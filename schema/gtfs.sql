DROP SCHEMA IF EXISTS gtfs CASCADE;

CREATE SCHEMA gtfs;

DROP DOMAIN IF EXISTS wgs84_lat CASCADE;

CREATE DOMAIN wgs84_lat AS double precision CHECK(VALUE >= -180 AND VALUE <= 180);

DROP DOMAIN IF EXISTS wgs84_lon CASCADE;

CREATE DOMAIN wgs84_lon AS double precision CHECK(VALUE >= -90 AND VALUE <= 90);

DROP DOMAIN IF EXISTS gtfstime CASCADE;

CREATE DOMAIN gtfstime AS text CHECK(VALUE ~ '^[0-9]?[0-9]:[0-5][0-9]:[0-5][0-9]$');

\i agency.sql
\i stops.sql
\i routes.sql
\i calendar.sql
\i shapes.sql
\i trips.sql
\i stop_times.sql
\i frequencies.sql

\copy gtfs.agency from '../fixtures/agency.txt' with csv header
\copy gtfs.stops from '../fixtures/stops.txt' with csv header
\copy gtfs.routes from '../fixtures/routes.txt' with csv header
\copy gtfs.calendar from '../fixtures/calendar.txt' with csv header
\copy gtfs.trips from '../fixtures/trips.txt' with csv header
\copy gtfs.stop_times from '../fixtures/stop_times.txt' with csv header
