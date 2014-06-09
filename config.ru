require 'date'
require 'rubygems'
require 'bundler'
Bundler.require

require_relative 'lib/server/real_time_finder'
require_relative 'lib/server/server'

run Server::Server
