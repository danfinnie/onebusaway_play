require 'date'
require 'rubygems'
require 'bundler'
Bundler.require

require File.expand_path '../lib/gtfs_server.rb', __FILE__

run GtfsServer
