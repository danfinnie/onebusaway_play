This is a play install of the GTFS library OneBusAway.  To run it:

1. Drop a zipped GTFS file called `njt_rail.zip` in the `gtfs_files` directory.
2. Run `docker build -t onebusaway .`
3. For development, run `docker run -p 9292:9292
  -v=`pwd`/public:/opt/onebusaway_play/public --name yolo onebusaway_play`.  This
  command names the volume `yolo` so you can kill it easily, and maps the public/
  folder so you can modify the JavaScript without recreating the container.  
4. For production, run `docker run -p 9292:9292 onebusaway_play`.  Or use
  something like my [reverse proxy](https://github.com/danfinnie/reverse_proxy)
  to put it on a subdomain.

Starting a server
=================

You can manually put files in the gtfs_files directory, or run some scripts to
download them.  For the automatic scripts:

1. Copy `.env.example` to `.env`.
2. Sign up for an NJTransit developers account and put the credentials in `.env`.
3. Run `./download.rb` to download GTFS data from NJTransit and the MTA (New York's public transit).
4. Run `./import.rb gtfs_files/*` to import all of the downloaded GTFS files to the SQL database.
5. Run `rackup` to start the HTTP server.
6. Visit `http://localhost:9292` to view your live updating map!
