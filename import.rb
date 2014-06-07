#! /usr/bin/env ruby

require 'csv'

require 'bundler'
Bundler.require

def csv_join(array, sep='')
  "(" + sep + array.join(sep + ', ' + sep) + sep + ")"
end

def log_and_execute(sql)
  puts sql
  $db.execute(sql)
end

$i = 0

# Generate schema
$db = SQLite3::Database.new "db.db"
$db.execute_batch(File.read('schema.sql'))
$db.synchronous = :off
# $db.journal_mode = :memory

# Bulk load all data
$db.transaction do
  Dir["gtfs_files/*.zip"].each do |zip_file_name|
    Dir.mktmpdir("gtfs_importer") do |tmp_dir|
      `unzip "#{zip_file_name}" -d "#{tmp_dir}"`
      Dir[tmp_dir + "/*"].each do |file_name|
        File.open(file_name) do |f|
          table_name = file_name[/.*\/(.*)\./, 1]
          csv = CSV.new(f, headers: true)
          csv.gets
          columns = csv.headers
          quoted_columns = csv_join(columns)
          csv.rewind # Need to have fetched to get the headers

          value_placeholder = csv_join(Array.new(columns.size, "?"))
          stmt = $db.prepare("insert into #{table_name} #{quoted_columns} values #{value_placeholder}")

          puts "Extracting #{file_name} from #{zip_file_name}"

          csv.each do |csv_row|
            values = csv_row.to_a.transpose[1]
            p values if ($i += 1) % 10_000 == 0
            stmt.execute(*values)
          end
        end
      end
    end
  end
end

# Add indicies??
