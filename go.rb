#! /usr/bin/env ruby

require 'bundler'
Bundler.require

get '/trains' do
  time = GregorianCalendar.new
  base_service_date = ServiceDate.new(time)

  res = (-1..1).map do |service_date_offset|
    service_date = base_service_date.shift(service_date_offset)
    services = calendar_service.get_service_ids_on_date(service_date)

    services.map do |service|
      agency = store.get_agency_for_id(service.agency_id)
      timezone = TimeZone.getTimeZone(agency.timezone)
      localized_service_date = service_date.getAsCalendar(timezone)

      store.get_trips_for_service_id(service).map do |trip|
        catch(:found_position) do
          store.get_stop_times_for_trip(trip).each_cons(2) do |from_stop_time, to_stop_time|
            from_time = localized_service_date.clone
            from_time.add(Calendar::SECOND, from_stop_time.departure_time);

            to_time = localized_service_date.clone
            to_time.add(Calendar::SECOND, to_stop_time.arrival_time);

            if from_time.compare_to(time) < 0 and to_time.compare_to(time) > 0
              percent_complete = (time.getTimeInMillis - from_time.getTimeInMillis).to_f / (to_time.getTimeInMillis - from_time.getTimeInMillis)
              lat = from_stop_time.stop.lat + (to_stop_time.stop.lat - from_stop_time.stop.lat) * percent_complete
              lon = from_stop_time.stop.lon + (to_stop_time.stop.lon - from_stop_time.stop.lon) * percent_complete
              throw :found_position, { trip_id: trip.id.hashCode, trip_name: trip.trip_headsign, lat: lat, lon: lon}
            end
          end
          nil
        end
      end
    end
  end

  json data: res.flatten.compact
end

get '/' do
  send_file 'public/index.html'
end

get 'script.js' do
  content_type 'application/json'
  send_file 'public/script.js'
end

get 'train.png' do
  content_type 'image/png'
  send_file 'public/train.png'
end
