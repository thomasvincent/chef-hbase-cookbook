source 'https://rubygems.org'

# Core Chef development tools
# Use the latest available Chef 18 release
gem 'chef', '~> 18.0'
gem 'chef-cli', '~> 5.6'

# Pin psych to avoid compilation issues with Ruby 3.2+
gem 'psych', '< 5'

# Testing frameworks
gem 'chefspec', '~> 9.3'
# Use inspec-core (not inspec) to avoid commercial chef-licensing requirement in InSpec 7+.
# inspec-core 6.x does not require a license key, only CHEF_LICENSE EULA acceptance.
gem 'inspec-core', '~> 6.0'
gem 'test-kitchen', '~> 4.0'

# Test Kitchen drivers
gem 'kitchen-dokken', '~> 2.20'
# 3.1+ supports test-kitchen 4.x and inspec-core 6.x/7.x
gem 'kitchen-inspec', '~> 3.1'

# Code quality and linting
gem 'cookstyle', '~> 8.1'

group :development do
  gem 'rb-readline'
  gem 'rake', '~> 13.0'
end

group :test do
  # ChefSpec 9.3.6 is incompatible with RSpec 3.13+ (removed expecteds_for_multiple_diffs)
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
