#! /usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require

java_import 'org.onebusaway.gtfs.serialization.GtfsReader'

reader = GtfsReader.new
p reader

# GtfsReader reader = new GtfsReader();
# reader.setInputLocation(new File(args[0]));

# /**
  # * You can register an entity handler that listens for new objects as they
  # * are read
  # */
  # reader.addEntityHandler(new GtfsEntityHandler());

# /**
  # * Or you can use the internal entity store, which has references to all the
  # * loaded entities
  # */
  # GtfsDaoImpl store = new GtfsDaoImpl();
# reader.setEntityStore(store);

# reader.run();

# // Access entities through the store
# for (Route route : store.getAllRoutes()) {
  # System.out.println("route: " + route.getShortName());
# }
# end
