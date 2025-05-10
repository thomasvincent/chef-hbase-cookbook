require 'chefspec'
require 'chefspec/berkshelf'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  add_filter '/.kitchen/'
  add_group 'Libraries', 'libraries'
  add_group 'Resources', 'resources'
  add_group 'Recipes', 'recipes'
end

at_exit { SimpleCov.result.format! }

RSpec.configure do |config|
  # Specify the operating system to mock Ohai data for
  config.platform = 'ubuntu'
  config.version = '22.04'
  
  # Specify the Chef log level (default: :warn)
  config.log_level = :error
  
  # Specify the Chef run context and cookbook path
  config.cookbook_path = ['..']
  
  # Include custom helpers
  config.include ChefSpec::Cacher
  
  # Enable expect syntax
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  
  # Enable shared contexts and shared examples
  config.shared_context_metadata_behavior = :apply_to_host_groups
  
  # Disable monkey patching
  config.disable_monkey_patching!
  
  # Use colored output
  config.color = true
  
  # Use detailed output for failures
  config.formatter = :documentation
  
  # Set a seed for randomizing test order
  config.order = :random
  Kernel.srand config.seed
end