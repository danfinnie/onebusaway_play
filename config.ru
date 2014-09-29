require 'date'
require 'rubygems'
require 'bundler'
Bundler.require(:development, :importer, :default)
Dotenv.load

require_relative 'lib/server/real_time_finder'
require_relative 'lib/server/server'

require_relative 'lib/importer/directory_importer'
require_relative 'lib/importer/zip_directory_importer'
require_relative 'lib/importer/importer'

db = SQLite3::Database.new ":memory:"

Thread.abort_on_exception = true
Thread.start do
  # sqlite3 must be compiled with threadsafe=1 for this to work without a mutex.  Mine was.
  worker_number = ENV['WORKER_NUMBER'].to_i
  s3 = AWS::S3.new(access_key_id: ENV['AWS_ACCESS_KEY'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
  bucket = s3.buckets['gtfs-files']
  s3object = bucket.objects.sort_by(&:key)[worker_number]

  File.open('gtfs_files/s3.zip', 'wb') do |file|
    s3object.read do |chunk|
      file.write(chunk)
    end
  end

  Importer::Importer.new(db, ['gtfs_files/s3.zip']).import!
end

run Server::Server.new(db)
