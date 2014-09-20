require 'csv'

module Importer
  class Importer
    def csv_join(array, sep='')
      "(" + sep + array.join(sep + ', ' + sep) + sep + ")"
    end

    def initialize db, files
      @db = db
      @files = files
    end

    attr_reader :files
    private :files

    def import!
      # Generate schema
      @db.execute_batch(File.read('schema.sql'))
      @db.synchronous = :off
      # @db.journal_mode = :memory

      # Bulk load all data
      @db.transaction do
        ZipDirectoryImporter.new(files).each_with_index do |metadata, dataset_id|
          directory_importer, dataset_name = metadata
          directory_importer.each do |f, logger, progress|
            csv_options = { headers: true }
            table_name = f.path[/.*\/(.*)\./, 1]

            # Don't judge... MTA's Manhattan bus file has malformed data.
            if table_name == "trips" && dataset_name =~ /manhattan.*bus/
              csv_options[:quote_char] = "\x00"
            end

            csv = CSV.new(f, csv_options)
            csv.gets
            columns = csv.headers + ["dataset_id"]
            quoted_columns = csv_join(columns)
            csv.rewind # Need to have fetched to get the headers

            value_placeholder = csv_join(Array.new(columns.size, "?"))
            stmt = @db.prepare("insert into #{table_name} #{quoted_columns} values #{value_placeholder}")

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

      @db.close
      puts "Done!"

      # Add indicies??
    end
  end
end
