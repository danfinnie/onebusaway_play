#! /usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require

java_import 'org.onebusaway.gtfs.serialization.GtfsReader'
java_import 'org.onebusaway.gtfs.impl.GtfsRelationalDaoImpl'
java_import 'org.onebusaway.gtfs.model.calendar.ServiceDate'
java_import 'org.onebusaway.gtfs.impl.calendar.CalendarServiceDataFactoryImpl'
java_import 'org.onebusaway.gtfs.impl.calendar.CalendarServiceImpl'
java_import 'org.jruby.util.JRubyFile'
java_import 'java.util.GregorianCalendar'
java_import 'java.util.Calendar'
java_import 'java.text.SimpleDateFormat'

store = GtfsRelationalDaoImpl.new
reader = GtfsReader.new
reader.input_location = JRubyFile.create(Dir.getwd, File.join("gtfs_files", "njt_rail.zip"))
reader.entity_store = store
reader.run

factory = CalendarServiceDataFactoryImpl.new(store)
calendar_service = CalendarServiceImpl.new(factory.createData)

now = GregorianCalendar.new
# start_of_day = GregorianCalendar.new(now.get(Calendar::YEAR), now.get(Calendar::MONTH), now.get(Calendar::DAY_OF_MONTH))
service_date = ServiceDate.new(now)
services = calendar_service.get_service_ids_on_date(service_date)

date_format = SimpleDateFormat.new

services.each do |service|
  trips = store.get_trips_for_service_id(service)
  trips.each do |trip|
    stop_times = store.get_stop_times_for_trip(trip)
    stop_times.each_cons(2) do |from_stop_time, to_stop_time|
      # Minus ones below are because the service date class adds one to the month...ewww
      from_time = GregorianCalendar.new(service_date.year, service_date.month - 1, service_date.day, 0, 0, from_stop_time.departure_time)
      to_time = GregorianCalendar.new(service_date.year, service_date.month - 1, service_date.day, 0, 0, to_stop_time.arrival_time)
      # The timezone below is wrong.
      if from_time.compare_to(now) < 0 and to_time.compare_to(now) > 0 
        percent_complete = (now.getTimeInMillis - from_time.getTimeInMillis).to_f / (to_time.getTimeInMillis - from_time.getTimeInMillis)
        lat = from_stop_time.stop.lat + (to_stop_time.stop.lat - from_stop_time.stop.lat) * percent_complete
        lon = from_stop_time.stop.lon + (to_stop_time.stop.lon - from_stop_time.stop.lon) * percent_complete
        puts "Service #{trip.trip_headsign} leaves #{from_stop_time.stop.name} at #{date_format.format(from_time.getTime)} and arrives at #{to_stop_time.stop.name} at #{date_format.format(to_time.getTime)}, it's at [#{lat}, #{lon}]!"
      end
    end
  end
end
