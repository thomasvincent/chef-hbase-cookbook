require 'rspec/core/rake_task'
require 'cookstyle'
require 'rubocop/rake_task'
require 'yard'

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
  desc 'Run Test Kitchen'
  task :kitchen do
    sh 'kitchen test'
  end

  desc 'Run Test Kitchen for a specific platform'
  task :platform, [:platform] do |_t, args|
    sh "kitchen test #{args[:platform]}"
  end

  desc 'Run Test Kitchen for a specific suite'
  task :suite, [:suite] do |_t, args|
    sh "kitchen test #{args[:suite]}"
  end

  desc 'Run a specific Test Kitchen instance'
  task :instance, [:instance] do |_t, args|
    sh "kitchen test #{args[:instance]}"
  end
end

# Documentation
namespace :docs do
  desc 'Generate documentation with YARD'
  YARD::Rake::YardocTask.new do |t|
    t.files = ['**/*.rb', '-', 'README.md', 'CHANGELOG.md', 'LICENSE']
    t.options = ['--markup-provider=redcarpet', '--markup=markdown']
  end
end

# Default tasks
desc 'Run all tests except Kitchen'
task default: %w(style spec)

desc 'Run all tests'
task test: ['style', 'spec', 'integration:kitchen']

desc 'Generate documentation'
task doc: ['docs:yard']
