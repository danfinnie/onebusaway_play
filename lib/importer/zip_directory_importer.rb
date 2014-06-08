module Importer
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

    def initialize(files)
      @files = files.map { |x| Zip.new(x, self) }
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
          yield directory_importer, file.path
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
end
