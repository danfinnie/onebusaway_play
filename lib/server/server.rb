module Server
  class Server < Sinatra::Base
    def initialize(db)
      super()
      @db = db
    end

    attr_reader :db
    private :db

    get '/trains' do
      headers "Access-Control-Allow-Origin" => "*"
      json data: finder.find(DateTime.now)
    end

    get '/' do
      send_file 'public/index.html'
    end

    get '/script.js' do
      content_type 'application/javascript'
      erb :'script.js', locals: { num_workers: ENV['NUM_WORKERS'].to_i }
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
