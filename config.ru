require 'date'
require 'rubygems'
require 'bundler'
Bundler.require

require File.expand_path '../lib/server/gtfs_server.rb', __FILE__

run Server::Gtfs
