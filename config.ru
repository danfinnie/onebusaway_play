require 'rubygems'
require 'bundler'
Bundler.require

require File.expand_path '../go.rb', __FILE__

run GtfsServer
