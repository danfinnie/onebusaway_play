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
