#! /usr/bin/env ruby

require 'uri'
require 'bundler'
Bundler.require(:download, :development)
Dotenv.load

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :phantomjs_options => ['--ignore-ssl-errors=yes', '--local-to-remote-url-access=yes'])
end

Capybara.run_server = false
Capybara.current_driver = :poltergeist

def sh cmd
  puts cmd
  `#{cmd}`
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
    sh %Q{curl -k -b JSESSIONID=#{cookie_value} -o "./gtfs_files/njt_#{type.downcase}.zip" "#{absolute_url}"`}
  end
end

module MTA
  %w[
    http://web.mta.info/developers/data/nyct/bus/google_transit_{bronx,brooklyn,manhattan,queens,staten_island}.zip
    http://web.mta.info/developers/data/nyct/subway/google_transit.zip
    http://web.mta.info/developers/data/{lirr,mnr,busco}/google_transit.zip
  ].each do |curl_url|
    pid = Process.spawn(%Q{curl -O  "#{curl_url}"}, chdir: './gtfs_files')
    Process.wait(pid)
  end
end
