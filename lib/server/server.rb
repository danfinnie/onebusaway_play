module Server
  class Server < Sinatra::Base
    def initialize(db)
      super()
      @db = db
    end

    attr_reader :db
    private :db

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

    get '/status' do
      content_type 'text/plain'
      send_file LOG
    end

    private

    def finder
      @finder ||= RealTimeFinder.new(db)
    end
  end
end
