#! /usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require

java_import 'org.onebusaway.gtfs.serialization.GtfsReader'
java_import 'org.onebusaway.gtfs.impl.GtfsDaoImpl'
java_import 'org.jruby.util.JRubyFile'

store = GtfsDaoImpl.new
reader = GtfsReader.new
reader.input_location = JRubyFile.create(Dir.getwd, "google_transit.zip")
reader.entity_store = store
reader.run

store.all_routes.each do |hi|
  puts hi.short_name
end
