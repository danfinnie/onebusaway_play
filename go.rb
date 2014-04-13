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
    stop_times.each_cons(2) do |from_stop_time, to_stop_time|
      from_time = GregorianCalendar.new(service_date.year, service_date.month, service_date.day, 0, 0, from_stop_time.departure_time)
      to_time = GregorianCalendar.new(service_date.year, service_date.month, service_date.day, 0, 0, to_stop_time.arrival_time)
      puts "Service #{trip.trip_headsign} leaves #{from_stop_time.stop.name} at #{date_format.format(from_time.getTime)} and arrives at #{to_stop_time.stop.name} at #{date_format.format(to_time.getTime)}"
    end
  end
end
