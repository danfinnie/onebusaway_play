#! /usr/bin/env ruby

require 'bundler'
Bundler.require

require_relative 'lib/importer/directory_importer'
require_relative 'lib/importer/zip_directory_importer'
require_relative 'lib/importer/importer'

raise "Must select at least one file to import" if ARGV.empty?

db = SQLite3::Database.new "db.db"
Importer::Importer.new(db, ARGV).import!
