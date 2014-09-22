#! /usr/bin/env ruby

require 'uri'
require 'bundler'
require 'cgi'
Bundler.require(:download, :development)
Dotenv.load

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    phantomjs: File.absolute_path('./lib/downloader/phantomjs'),
    phantomjs_options: ['--ignore-ssl-errors=yes', '--local-to-remote-url-access=yes']
  )
end

Capybara.run_server = false
Capybara.current_driver = :poltergeist

def download_url(url, curl_opts="")
  url = url.to_s
  file_system_escaped_url = CGI::escape(url)
  cmd = %Q{curl -o #{file_system_escaped_url} #{curl_opts} "#{url}"}
  puts cmd
  pid = Process.spawn(cmd, chdir: './gtfs_files')
  Process.wait(pid)
end

module NJTransit
  extend Capybara::DSL
  visit "https://www.njtransit.com/developers"
  fill_in "userName", with: ENV['NJTRANSIT_USERNAME']
  fill_in "password", with: ENV['NJTRANSIT_PASSWORD']
  click_on "Login"
  cookie_value = page.driver.cookies['JSESSIONID'].value

  ["Rail", "Bus"].each do |type|
    link_text = type + " Data"
    link = find_link(link_text)
    relative_url = link['href']
    absolute_url = URI::join(current_url, relative_url)
    download_url absolute_url, "-k -b JSESSIONID=#{cookie_value}"
  end
end

module MTA
  %w[
    http://web.mta.info/developers/data/nyct/bus/google_transit_bronx.zip
    http://web.mta.info/developers/data/nyct/bus/google_transit_brooklyn.zip
    http://web.mta.info/developers/data/nyct/bus/google_transit_manhattan.zip
    http://web.mta.info/developers/data/nyct/bus/google_transit_queens.zip
    http://web.mta.info/developers/data/nyct/bus/google_transit_staten_island.zip
    http://web.mta.info/developers/data/nyct/subway/google_transit.zip
    http://web.mta.info/developers/data/lirr/google_transit.zip
    http://web.mta.info/developers/data/mnr/google_transit.zip
    http://web.mta.info/developers/data/busco/google_transit.zip
  ].each do |url|
    download_url url
  end
end

module PATH
  # download_url 'http://trilliumtransit.com/transit_feeds/path-nj-us/gtfs.zip'
end
