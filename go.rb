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
java_import 'java.text.SimpleDateFormat'

store = GtfsRelationalDaoImpl.new
reader = GtfsReader.new
reader.input_location = JRubyFile.create(Dir.getwd, File.join("gtfs_files", "njt_rail.zip"))
reader.entity_store = store
reader.run

factory = CalendarServiceDataFactoryImpl.new(store)
calendar_service = CalendarServiceImpl.new(factory.createData)

service_date = ServiceDate.new # for today
services = calendar_service.get_service_ids_on_date(service_date)

date_format = SimpleDateFormat.new

services.each do |service|
  trips = store.get_trips_for_service_id(service)
  trips.each do |trip|
    stop_times = store.get_stop_times_for_trip(trip)
    stop_times.each do |stop_time|
      arrival = GregorianCalendar.new(service_date.year, service_date.month, service_date.day, 0, 0, stop_time.arrival_time)
      puts "At #{date_format.format(arrival.getTime)}, #{trip.trip_headsign} stops at #{stop_time.stop.name}"
    end
  end

end
