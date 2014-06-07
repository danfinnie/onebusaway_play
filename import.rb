#! /usr/bin/env ruby

require 'csv'

require 'bundler'
Bundler.require

def csv_join(array, sep='')
  "(" + sep + array.join(sep + ', ' + sep) + sep + ")"
end

$i = 0

# Generate schema
$db = SQLite3::Database.new "db.db"
$db.execute_batch(File.read('schema.sql'))
$db.synchronous = :off
# $db.journal_mode = :memory

class DirectoryImporter
  def initialize(path:, progress_reporter:, log:)
    @path, @progress_reporter, @log = path, progress_reporter, log
  end

  attr_reader :path

  def each
    files = Dir[@path + "/*"].map { |file_name| [file_name, File.size(file_name)] }
    total_size = files.sum { |file| file[1] }

    files.inject(0) do |imported_size, file_metadata|
      file_name, file_size = file_metadata
      @progress_reporter[imported_size.to_f / total_size]
      File.open(file_name) do |f|
        progress_function = -> { @progress_reporter.((imported_size + f.tell).to_f / total_size) }
        yield f, @log, progress_function
      end
      return imported_size + file_size
    end
  end
end

# Given a directory of zip files, import each file with a progress bar.
class ZipDirectoryImporter
  class Zip
    def initialize(path, progress_notifier)
      @path = path
      @progress_notifier = progress_notifier
      @fraction_complete = 0.0
    end

    attr_reader :path, :fraction_complete

    def size
      @size ||= File.size(@path)
    end

    def fraction_complete= fraction_complete
      @fraction_complete = fraction_complete
      @progress_notifier.progress_has_changed!
    end
  end

  include Enumerable

  def initialize(dir)
    @files = Dir["gtfs_files/*.zip"].map { |x| Zip.new(x, self) }
    @i = 0
  end

  def each
    @progress_bar = ProgressBar.create(total: total_size, format: '%a %P%% %B %e', throttle_rate: 0.1)
    @files.each do |file|
      Dir.mktmpdir("gtfs_importer") do |tmp_dir|
        `unzip "#{file.path}" -d "#{tmp_dir}"`
        directory_importer = DirectoryImporter.new(
          path: tmp_dir,
          progress_reporter: -> (new_value) { file.fraction_complete = new_value },
          log: -> (*args) { self.log(*args) }
        )
        yield directory_importer
      end
    end
    @progress_bar.finish
  end

  def progress_has_changed!
    @progress_bar.progress = progress
  end

  def progress
    @files.sum do |file|
      file.size * file.fraction_complete
    end
  end

  def total_size
    @files.sum(&:size)
  end

  def log(frequency, message)
    @i += 1

    if frequency == :sometimes
      return unless @i % 10_000 == 0
    end

    @progress_bar.log(message)
  end
end


# Bulk load all data
$db.transaction do
  ZipDirectoryImporter.new("gtfs_files").each_with_index do |directory_importer, dataset_id|
    directory_importer.each do |f, logger, progress|
      csv_options = { headers: true }
      table_name = f.path[/.*\/(.*)\./, 1]

      # Don't judge... MTA's Manhattan bus file has malformed data.
      if table_name == "trips" && zip_file_name =~ /manhattan.*bus/
        csv_options[:quote_char] = "\x00"
      end

      csv = CSV.new(f, csv_options)
      csv.gets
      columns = csv.headers + ["dataset_id"]
      quoted_columns = csv_join(columns)
      csv.rewind # Need to have fetched to get the headers

      value_placeholder = csv_join(Array.new(columns.size, "?"))
      stmt = $db.prepare("insert into #{table_name} #{quoted_columns} values #{value_placeholder}")

      logger.(:always, "Extracting #{table_name} from #{directory_importer.path}")

      csv.each do |csv_row|
        values = csv_row.to_a.transpose[1]
        logger.(:sometimes, values.inspect)
        stmt.execute(*values, dataset_id)
        progress.()
      end

      stmt.close
    end
  end
end

$db.close
puts "Done!"

# Add indicies??
