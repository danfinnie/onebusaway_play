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
java_import 'java.util.TimeZone'
java_import 'java.text.SimpleDateFormat'

store = GtfsRelationalDaoImpl.new
reader = GtfsReader.new
reader.input_location = JRubyFile.create(Dir.getwd, File.join("gtfs_files", "njt_rail.zip"))
reader.entity_store = store
reader.run

factory = CalendarServiceDataFactoryImpl.new(store)
calendar_service = CalendarServiceImpl.new(factory.createData)

get '/trains' do
  # start_of_day = GregorianCalendar.new(now.get(Calendar::YEAR), now.get(Calendar::MONTH), now.get(Calendar::DAY_OF_MONTH))
  service_date = ServiceDate.new
  services = calendar_service.get_service_ids_on_date(service_date)

  date_format = SimpleDateFormat.new

  res = services.map do |service|
    agency = store.get_agency_for_id(service.agency_id)
    timezone = TimeZone.getTimeZone(agency.timezone)
    now = service_date.getAsCalendar(timezone)

    store.get_trips_for_service_id(service).map do |trip|
      catch(:found_position) do
        store.get_stop_times_for_trip(trip).each_cons(2) do |from_stop_time, to_stop_time|
          from_time = now.clone
          ServiceDate.moveCalendarToServiceDate(from_time)
          from_time.add(Calendar::SECOND, from_stop_time.departure_time);
          from_time.add(Calendar::HOUR, -4) # Bad

          to_time = now.clone
          ServiceDate.moveCalendarToServiceDate(to_time)
          to_time.add(Calendar::SECOND, to_stop_time.arrival_time);
          to_time.add(Calendar::HOUR, -4) # Bad

          if from_time.compare_to(now) < 0 and to_time.compare_to(now) > 0
            percent_complete = (now.getTimeInMillis - from_time.getTimeInMillis).to_f / (to_time.getTimeInMillis - from_time.getTimeInMillis)
            lat = from_stop_time.stop.lat + (to_stop_time.stop.lat - from_stop_time.stop.lat) * percent_complete
            lon = from_stop_time.stop.lon + (to_stop_time.stop.lon - from_stop_time.stop.lon) * percent_complete
            throw :found_position, { trip_id: trip.id.hashCode, trip_name: trip.trip_headsign, lat: lat, lon: lon}
          end
        end
        nil
      end
    end
  end

  json data: res.flatten.compact
end

get '/' do
  send_file 'public/index.html'
end
