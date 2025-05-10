require 'rspec/core/rake_task'
require 'cookstyle'
require 'rubocop/rake_task'
require 'kitchen/rake_tasks'

# Style tests. Cookstyle (rubocop) and Foodcritic
namespace :style do
  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby) do |task|
    task.options << '--display-cop-names'
  end
end

desc 'Run all style checks'
task style: ['style:ruby']

# Rspec and ChefSpec
desc 'Run ChefSpec examples'
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = '--color --format documentation'
end

# Integration tests. Kitchen.ci
namespace :integration do
  desc 'Run Test Kitchen with Docker'
  task :docker do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      instance.test(:always)
    end
  end
end

# Default
desc 'Run all tests except Kitchen'
task default: ['style', 'spec']

desc 'Run all tests'
task test: ['style', 'spec', 'integration:docker']