#! /usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require

java_import 'org.onebusaway.gtfs.serialization.GtfsReader'
java_import 'org.onebusaway.gtfs.impl.GtfsDaoImpl'
java_import 'org.jruby.util.JRubyFile'

store = GtfsDaoImpl.new
reader = GtfsReader.new
reader.setInputLocation(JRubyFile.create(Dir.getwd, "google_transit.zip"))
reader.setEntityStore(store)
reader.run

store.getAllRoutes.each do |hi|
  puts hi.getShortName
end
