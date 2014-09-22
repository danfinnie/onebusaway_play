source 'https://rubygems.org'

ruby '2.1.2'

gem 'sinatra', require: 'sinatra/base'
gem 'sinatra-contrib'
gem 'sqlite3'
gem 'ruby-progressbar'
gem 'awesome_print'
gem 'aws-sdk'
gem 'dotenv'
gem 'activesupport', '~> 4.1.1', require: [
  'active_support',
  'active_support/core_ext/hash/indifferent_access',
  'active_support/core_ext/numeric/time',
  'active_support/core_ext/date',
  'active_support/core_ext/date_time'
]

group :download do
  gem 'capybara'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'dotenv'
end

group :development do
  gem 'pry'
  gem 'launchy'
end
