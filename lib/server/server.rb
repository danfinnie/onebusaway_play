module Server
  class Server < Sinatra::Base
    def initialize(db)
      super()
      @continual_finder = ContinualFinder.new(db)
    end

    attr_reader :continual_finder
    private :continual_finder

    get '/trains' do
      headers "Access-Control-Allow-Origin" => "*"
      json data: continual_finder.latest
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
  end
end
