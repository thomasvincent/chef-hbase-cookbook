source 'https://rubygems.org'

# Core Chef development tools
# Use the latest available Chef 18 release
gem 'chef', '~> 18.0'
gem 'chef-cli', '~> 5.6'

# Testing frameworks
gem 'chefspec', '~> 9.3'
# kitchen-inspec is limited to inspec < 7, so stick to the 6.x series for now.
gem 'inspec', '~> 6.0'
gem 'test-kitchen', '~> 4.0'

# Test Kitchen drivers
gem 'kitchen-dokken', '~> 2.20'
gem 'kitchen-inspec', '~> 3.0'

# Code quality and linting
gem 'cookstyle', '~> 8.1'

group :development do
  gem 'rb-readline'
  gem 'rake', '~> 13.0'
end

group :test do
  # ChefSpec 9 requires RSpec < 3.12
  gem 'rspec', '>= 3.11', '< 3.14'
  gem 'rspec-its', '~> 1.3'
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-console', '~> 0.9'
  gem 'rspec_junit_formatter'
end

group :docs do
  gem 'yard', '~> 0.9'
  gem 'redcarpet', '~> 3.5'
end
