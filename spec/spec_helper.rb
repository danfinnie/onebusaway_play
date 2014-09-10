require 'date'

require 'bundler'
Bundler.require

require_relative '../lib/server/real_time_finder'
require_relative '../lib/server/server'
require_relative '../lib/importer/directory_importer'
require_relative '../lib/importer/zip_directory_importer'
require_relative '../lib/importer/importer'

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
end
