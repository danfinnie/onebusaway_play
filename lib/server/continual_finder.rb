require 'thread'

module Server
  class ContinualFinder
    def initialize(db)
      @semaphore = Mutex.new
      @latest = nil

      processor = Thread.start do
        real_time_finder = RealTimeFinder.new(db)
        loop do
          begin
            time = DateTime.now
            results = real_time_finder.find(time)
            $stderr.puts "Generating results for #{time}"
            @semaphore.synchronize do
              @latest = results
            end
            Thread.pass
            sleep 1
          rescue SQLite3::SQLException
            # The tables are probably not filled yet
            sleep 10
          end
        end
      end
      processor.priority = -10
    end

    def latest
      @semaphore.synchronize do
        @latest
      end
    end
  end
end
