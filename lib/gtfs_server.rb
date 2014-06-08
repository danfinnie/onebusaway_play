class GtfsServer < Sinatra::Base
  get '/trains' do
    time = DateTime.now
    data = get_calendar_inclusions(time) # + get_calendar_results(time)

    data = data.select do |result|
      arrival_time = calculate_gtfs_time(time, result[:arrival_time])
      departure_time = calculate_gtfs_time(time, result[:departure_time])
      time < arrival_time && time > departure_time
    end.map do |result|
      arrival_time = calculate_gtfs_time(time, result[:arrival_time])
      departure_time = calculate_gtfs_time(time, result[:departure_time])
      percent_complete = (time.to_i - departure_time.to_i).to_f / (arrival_time.to_i - departure_time.to_i)
      from_lat, to_lat, from_lon, to_lon = result.values_at(:from_lat, :to_lat, :from_lon, :to_lon)
      lat = from_lat + (to_lat - from_lat) * percent_complete
      lon = from_lon + (to_lon - from_lon) * percent_complete
      trip_id, trip_headsign = result.values_at(:trip_id, :trip_headsign)
      { trip_id: trip_id, trip_name: trip_headsign, lat: lat, lon: lon }
    end

    json data: data
  end

  get '/' do
    send_file 'public/index.html'
  end

  get '/script.js' do
    content_type 'application/javascript'
    send_file 'public/script.js'
  end

  get '/train.png' do
    content_type 'image/png'
    send_file 'public/train.png'
  end

  def initialize
    @db = SQLite3::Database.new "db.db"
    @db.results_as_hash = true
    super
  end

  private

  def query query
    @db.execute(query).map(&:with_indifferent_access)
  end

  def calculate_gtfs_time(base, offset_str)
    offset_int = offset_str.split(':').inject(0) { |memo, section| memo * 60 + section.to_i }
    gtfs_base_time = base.at_noon - 12.hours
    gtfs_base_time.advance(seconds: offset_int) # Cannot just use #+ because that would advance the DateTime object above by days, not seconds.
  end

  # Get weekly services that coincide with the time.
  def get_calendar_results time
    weekday = time.strftime("%A").downcase

    calendar_results = query <<-"EOT"
      SELECT
        from_time.departure_time,
        to_time.arrival_time,
        trip.trip_headsign,
        trip.trip_id,
        from_stop.stop_lat as from_lat,
        from_stop.stop_lon as from_lon,
        to_stop.stop_lat as to_lat,
        to_stop.stop_lon as to_lon,
        calendar.start_date,
        calendar.end_date
      FROM stop_times from_time
      JOIN stop_times to_time
      JOIN trips trip
      JOIN calendar calendar
      JOIN stops from_stop
      JOIN stops to_stop
      WHERE from_time.dataset_id = to_time.dataset_id
      AND trip.trip_id = from_time.trip_id
      AND trip.dataset_id = from_time.dataset_id
      AND calendar.service_id = trip.service_id
      AND calendar.dataset_id = from_time.dataset_id
      AND from_stop.dataset_id = from_time.dataset_id
      AND to_stop.dataset_id = from_time.dataset_id
      AND from_stop.stop_id = from_time.stop_id
      AND to_stop.stop_id = to_time.stop_id
      AND from_time.trip_id = to_time.trip_id
      AND from_time.stop_id + 1 = to_time.stop_id
      AND calendar.#{weekday} = 1
      ;
    EOT

    calendar_results.select do |result|
      service_start_date = DateTime.strptime(result[:start_date], "%Y%m%d")
      service_end_date = DateTime.strptime(result[:end_date], "%Y%m%d").next_day
      service_start_date < time && time < service_end_date
    end
  end

  # Get extra services for a day
  def get_calendar_inclusions time
    query <<-"EOT"
      SELECT
        from_time.departure_time,
        to_time.arrival_time,
        trip.trip_headsign,
        trip.trip_id,
        from_stop.stop_lat as from_lat,
        from_stop.stop_lon as from_lon,
        to_stop.stop_lat as to_lat,
        to_stop.stop_lon as to_lon
      FROM stop_times from_time
      JOIN stop_times to_time
      JOIN trips trip
      JOIN stops from_stop
      JOIN stops to_stop
      JOIN calendar_dates calendar_date
      WHERE from_time.dataset_id = to_time.dataset_id
      AND trip.trip_id = from_time.trip_id
      AND trip.dataset_id = from_time.dataset_id
      AND from_stop.dataset_id = from_time.dataset_id
      AND to_stop.dataset_id = from_time.dataset_id
      AND from_stop.stop_id = from_time.stop_id
      AND to_stop.stop_id = to_time.stop_id
      AND from_time.trip_id = to_time.trip_id
      AND from_time.stop_id + 1 = to_time.stop_id
      AND calendar_date.dataset_id = from_time.dataset_id
      AND calendar_date.service_id = trip.service_id
      AND calendar_date.exception_type = 1 -- service added constant
      AND calendar_date.date = "#{time.strftime('%Y%m%d')}"
      ;
    EOT
  end
end
