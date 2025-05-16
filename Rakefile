require 'rspec/core/rake_task'
require 'cookstyle'
require 'rubocop/rake_task'
require 'yard'

# Style tests using Cookstyle
namespace :style do
  desc 'Run Chef style checks via Cookstyle'
  RuboCop::RakeTask.new(:chef) do |task|
    task.options << '--display-cop-names'
    task.options << '--format progress'
  end
end

desc 'Run all style checks'
task style: ['style:chef']

# Rspec and ChefSpec
desc 'Run ChefSpec unit tests'
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = '--color --format documentation'
  task.pattern = 'spec/unit/**/*_spec.rb'
end

# Integration tests with Kitchen
namespace :integration do
  desc 'Run Test Kitchen with Docker'
  task :docker do
    sh 'KITCHEN_YAML=kitchen.docker.yml kitchen test'
  end

  desc 'Run Test Kitchen with Docker for a specific platform'
  task :platform, [:platform] do |_t, args|
    sh "KITCHEN_YAML=kitchen.docker.yml kitchen test #{args[:platform]}"
  end

  desc 'Run Test Kitchen for a specific suite'
  task :suite, [:suite] do |_t, args|
    sh "KITCHEN_YAML=kitchen.docker.yml kitchen test #{args[:suite]}"
  end

  desc 'Run Test Kitchen converge only (faster for development)'
  task :converge do
    sh 'KITCHEN_YAML=kitchen.docker.yml kitchen converge'
  end
  
  desc 'Run Test Kitchen verify only (without converge)'
  task :verify do
    sh 'KITCHEN_YAML=kitchen.docker.yml kitchen verify'
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

# Simplify kitchen commands
desc 'Run test-kitchen with Vagrant'
task :vagrant do
  ENV['KITCHEN_YAML'] = 'kitchen.yml'
  sh 'kitchen test'
end

desc 'Run test-kitchen with Docker'
task :docker do
  ENV['KITCHEN_YAML'] = 'kitchen.docker.yml'
  sh 'kitchen test'
end

# Add linting task for GitHub Actions compatibility
desc 'Run Cookstyle'
task lint: ['style:chef']

# Default tasks
desc 'Run all tests except Kitchen (fast)'
task default: ['style', 'spec']

desc 'Run all tests including Kitchen (slower, comprehensive)'
task all: ['style', 'spec', 'integration:docker']

desc 'Run CI pipeline (style, spec, integration)'
task ci: ['style', 'spec', 'integration:docker']

desc 'Generate documentation'
task doc: ['docs:yard']