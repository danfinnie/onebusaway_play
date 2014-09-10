DROP TABLE IF EXISTS calendar_dates;
CREATE TABLE calendar_dates
(
  dataset_id integer,
  service_id text,
  date text,
  exception_type text
);

DROP TABLE IF EXISTS feed_info;
CREATE TABLE feed_info
(
  dataset_id integer,
  feed_publisher_name text,
  feed_publisher_url text,
  feed_lang text,
  feed_start_date text,
  feed_end_date text,
  feed_version text,
  feed_timezone text, -- Specified by LIRR but not part of the spec
  PRIMARY KEY (dataset_id)
);

DROP TABLE IF EXISTS transfers;
CREATE TABLE transfers
(
  dataset_id integer,
  from_stop_id text,
  to_stop_id text,
  transfer_type integer,
  min_transfer_time integer
);

DROP TABLE IF EXISTS agency;
CREATE TABLE agency
(
  dataset_id integer,
  agency_id  text,
  agency_name  text,
  agency_url  text ,
  agency_timezone  text ,
  agency_lang  text,
  agency_phone  text,
  PRIMARY KEY (dataset_id, agency_id)
);

DROP TABLE IF EXISTS stops;

CREATE TABLE stops
(
  dataset_id integer,
  stop_id integer,
  stop_code  text,
  stop_name  text,
  stop_desc  text ,
  stop_lat  double,
  stop_lon  double,
  zone_id  text,
  stop_url  text,
  location_type  integer ,
  parent_station  text,
  wheelchair_accessible int,
  PRIMARY KEY (dataset_id, stop_id)
);


DROP TABLE IF EXISTS routes;

CREATE TABLE routes
(
  dataset_id integer,
  route_id  text,
  agency_id  text,
  route_short_name  text,
  route_long_name  text,
  route_desc  text,
  route_type  integer ,
  route_url  text,
  route_color  text,
  route_text_color  text,
  PRIMARY KEY (dataset_id, route_id)
);

DROP TABLE IF EXISTS calendar;

CREATE TABLE calendar
(
  dataset_id integer,
  service_id  text,
  monday  integer,
  tuesday integer,
  wednesday  integer,
  thursday  integer,
  friday  integer,
  saturday  integer,
  sunday  integer,
  start_date text,
  end_date text,
  PRIMARY KEY (dataset_id, service_id)
);

DROP TABLE IF EXISTS shapes;

CREATE TABLE shapes
(
  dataset_id integer,
  shape_id text,
  shape_pt_lat  double,
  shape_pt_lon  double,
  shape_pt_sequence  integer,
  shape_dist_traveled  double precision,
  PRIMARY KEY (dataset_id, shape_id, shape_pt_sequence)
);

DROP TABLE IF EXISTS trips;

CREATE TABLE trips
(
  dataset_id integer,
  route_id  text,
  service_id  text,
  trip_id  text,
  trip_headsign  text,
  trip_short_name  text,
  direction_id  integer,
  block_id  text,
  shape_id  text,
  wheelchair_accessible integer,
  wheelchair_boarding integer, -- not part of spec but metronorth provides this
  bikes_allowed integer,
  PRIMARY KEY (dataset_id, trip_id)
);

DROP TABLE IF EXISTS stop_times;

CREATE TABLE stop_times
(
  dataset_id integer,
  trip_id  text,
  arrival_time  text,
  departure_time  text,
  stop_id  text,
  stop_sequence  integer,
  stop_headsign  text,
  pickup_type  integer ,
  drop_off_type  integer ,
  shape_dist_traveled  double precision,
  drop_off_time
);


DROP TABLE IF EXISTS frequencies;

CREATE TABLE frequencies
(
  dataset_id integer,
  trip_id  text,
  start_time  text,
  end_time  text,
  headway_secs  integer 
);
