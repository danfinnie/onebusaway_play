module Server
  class Server < Sinatra::Base
    get '/trains' do
      # json data: []
      json data: finder.find(DateTime.now)
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

    private

    def finder
      @finder ||= RealTimeFinder.new(db)
    end

    def db
      @db ||= SQLite3::Database.new "db.db"
    end
  end
end