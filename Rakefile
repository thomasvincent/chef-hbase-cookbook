require 'rspec/core/rake_task'
require 'cookstyle'
require 'rubocop/rake_task'

# Style tests. Cookstyle (rubocop)
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

# Integration tests with Kitchen
namespace :integration do
  desc 'Run Test Kitchen with Docker'
  task :docker do
    sh 'KITCHEN_YAML=kitchen.docker.yml kitchen test'
  end

  desc 'Run Test Kitchen with Docker for a specific platform'
  task :docker_platform, [:platform] do |_t, args|
    sh "KITCHEN_YAML=kitchen.docker.yml kitchen test #{args[:platform]}"
  end

  desc 'Run Test Kitchen for a specific suite'
  task :suite, [:suite] do |_t, args|
    sh "KITCHEN_YAML=kitchen.docker.yml kitchen test #{args[:suite]}"
  end

  desc 'Run a specific Test Kitchen instance'
  task :instance, [:instance] do |_t, args|
    sh "KITCHEN_YAML=kitchen.docker.yml kitchen test #{args[:instance]}"
  end
end

# Default tasks
desc 'Run all tests except Kitchen'
task default: ['style', 'spec']

desc 'Run all tests'
task test: ['style', 'spec', 'integration:docker']