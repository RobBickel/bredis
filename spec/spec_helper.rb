require 'rubygems'
require 'bredis'

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'rspec/autorun'
require 'test/unit'
require 'mocha'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'coveralls'
Coveralls.wear!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.color_enabled = true

  config.before(:all) do
    
  end

  config.before(:each) do
    
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  
  # treats :focus to be true by default
  # config.treat_symbols_as_metadata_keys_with_true_values = true
  
  # runs only the specs who have focus tag
  # config.filter_run_including :focus => true
  
  # runs specs excluding specs with broken tag
  # config.filter_run_excluding :broken => true
  
  # runs all specs if filters are matched
  # config.run_all_when_everything_filtered = true
  
end
