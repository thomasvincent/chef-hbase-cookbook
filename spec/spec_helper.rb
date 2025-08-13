require 'chefspec'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  add_filter '/.kitchen/'
  add_group 'Libraries', 'libraries'
  add_group 'Resources', 'resources'
  add_group 'Recipes', 'recipes'
end

RSpec.configure do |config|
  # Specify the Chef license
  Chef::Config[:chef_license] = 'accept-silent'
  
  # Specify the operating system to mock Ohai data for
  config.platform = 'ubuntu'
  config.version = '20.04'
  
  # Specify the Chef log level (default: :warn)
  config.log_level = :error
  
  # Enable expect syntax
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  
  # Enable shared contexts and shared examples
  config.shared_context_metadata_behavior = :apply_to_host_groups
  
  # Use colored output
  config.color = true
  
  # Use detailed output for failures
  config.formatter = :documentation
end