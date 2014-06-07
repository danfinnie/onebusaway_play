DROP TABLE IF EXISTS agency;

DROP TABLE IF EXISTS calendar_dates;
CREATE TABLE calendar_dates
(
  service_id text,
  date text,
  exception_type text
);

DROP TABLE IF EXISTS feed_info;
CREATE TABLE feed_info
(
  feed_publisher_name text,
  feed_publisher_url text,
  feed_lang text,
  feed_start_date text,
  feed_end_date text,
  feed_version text,
  feed_timezone text -- Specified by LIRR but not part of the spec
);

CREATE TABLE agency
(
    agency_id  text UNIQUE NULL,
    agency_name  text NOT NULL,
    agency_url  text  NOT NULL,
    agency_timezone  text  NOT NULL,
    agency_lang  text NULL,
    agency_phone  text NULL
);

DROP TABLE IF EXISTS stops;

CREATE TABLE stops
(
    stop_id  text PRIMARY KEY,
    stop_code  text  UNIQUE NULL,
    stop_name  text NOT NULL,
    stop_desc  text  NULL,
    stop_lat  double NOT NULL,
    stop_lon  double NOT NULL,
    zone_id  text NULL,
    stop_url  text NULL,
    location_type  integer NULL ,
    parent_station  text NULL
);


DROP TABLE IF EXISTS routes;

CREATE TABLE routes
(
    route_id  text PRIMARY KEY,
    agency_id  text NULL,
    route_short_name  text NOT NULL,
    route_long_name  text NOT NULL,
    route_desc  text NULL,
    route_type  integer NOT NULL ,
    route_url  text NULL,
    route_color  text NULL,
    route_text_color  text NULL
);

DROP TABLE IF EXISTS calendar;

CREATE TABLE calendar
(
    service_id  text PRIMARY KEY,
    monday  integer,
    tuesday integer,
    wednesday  integer,
    thursday  integer,
    friday  integer,
    saturday  integer,
    sunday  integer,
    start_date text,
    end_date text
);

DROP TABLE IF EXISTS shapes;

CREATE TABLE shapes
(
    shape_id text,
    shape_pt_lat  double NOT NULL,
    shape_pt_lon  double NOT NULL,
    shape_pt_sequence  integer NOT NULL,
    shape_dist_traveled  double precision NULL,
    PRIMARY KEY (shape_id, shape_pt_sequence)
);

DROP TABLE IF EXISTS trips;

CREATE TABLE trips
(
    route_id  text NOT NULL,
    service_id  text NOT NULL,
    trip_id  text NOT NULL PRIMARY KEY,
    trip_headsign  text NULL,
    trip_short_name  text NULL,
    direction_id  integer NULL,
    block_id  text NULL,
    shape_id  text NULL
);

DROP TABLE IF EXISTS stop_times;

CREATE TABLE stop_times
(
    trip_id  text NOT NULL,
    arrival_time  text NOT NULL,
    departure_time  text NOT NULL,
    stop_id  text NOT NULL,
    stop_sequence  integer NOT NULL,
    stop_headsign  text NULL,
    pickup_type  integer NULL ,
    drop_off_type  integer NULL ,
    shape_dist_traveled  double precision NULL
);


DROP TABLE IF EXISTS frequencies;

CREATE TABLE frequencies
(
    trip_id  text NOT NULL,
    start_time  text NOT NULL,
    end_time  text NOT NULL,
    headway_secs  integer  NOT NULL
);
