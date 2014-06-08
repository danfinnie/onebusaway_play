module Importer
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
        imported_size + file_size
      end
    end
  end
end
