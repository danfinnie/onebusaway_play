source 'https://rubygems.org'
source 'http://gem-source-sqlite3.s3.amazonaws.com'

ruby '2.1.2'

# source 'file:///home/daniel/code/sqlite3-ruby' do
gem 'sqlite3'

gem 'bundler', '= 1.6.3' # Because we need the block form of source
gem 'sinatra', require: 'sinatra/base'
gem 'sinatra-contrib'
gem 'ruby-progressbar'
gem 'awesome_print'
gem 'aws-sdk'
gem 'dotenv'
gem 'unicorn'
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
end

group :development do
  gem 'pry'
  gem 'pry-byebug'
  gem 'launchy'
end
