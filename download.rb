#! /usr/bin/env ruby

# Download NJTransit, etc. GTFS files.

require 'uri'
require 'bundler'
Bundler.require(:download, :development)
Dotenv.load

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :phantomjs_options => ['--ignore-ssl-errors=yes', '--local-to-remote-url-access=yes'])
end

Capybara.run_server = false
Capybara.current_driver = :poltergeist

include Capybara::DSL

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
  puts %Q{curl -k -b JSESSIONID=#{cookie_value} -o "./gtfs_files/njt_#{type.downcase}.zip" "#{absolute_url}"}
  `curl -k -b JSESSIONID=#{cookie_value} -o "./gtfs_files/njt_#{type.downcase}.zip" "#{absolute_url}"`
end
