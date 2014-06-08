#! /usr/bin/env ruby

require 'bundler'
Bundler.require

require_relative 'lib/importer/directory_importer'
require_relative 'lib/importer/zip_directory_importer'
require_relative 'lib/importer/importer'

Importer::Importer.new.import!
