# HBase Cookbook

[![CI](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/ci.yml/badge.svg)](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/ci.yml)
[![pre-commit](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/pre-commit.yml)
![Chef Version](https://img.shields.io/badge/chef-%3E%3D%2018.0-blue)
![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)
![Maintenance](https://img.shields.io/maintenance/yes/2025)

This cookbook installs and configures Apache HBase - the Hadoop database, a distributed, scalable, big data store. It's designed to be modern, modular, and compliant with Chef Infra Client 18+ standards.

## Requirements

### Platforms

This cookbook is tested on the following platforms using Test Kitchen with the [kitchen-dokken](https://github.com/test-kitchen/kitchen-dokken) driver:

#### Actively Tested Platforms:
- Ubuntu 18.04, 20.04, 22.04
- Debian 10, 11
- RHEL/AlmaLinux/Rocky Linux 8, 9
- Amazon Linux 2, 2023
- Fedora (latest)
- openSUSE Leap 15
- CentOS 7 (legacy support)

#### Compatibility Matrix:
| Platform | Versions | Chef Support | Notes |
|----------|----------|--------------|-------|
| Ubuntu | 18.04, 20.04, 22.04 | Full | Recommended for production |
| Debian | 10, 11 | Full | Recommended for production |
| RHEL | 7, 8, 9 | Full | Enterprise ready |
| Rocky/AlmaLinux | 8, 9 | Full | RHEL compatible |
| Amazon Linux | 2, 2023 | Full | AWS optimized |
| openSUSE/SLES | 15 | Full | Enterprise ready |
| Fedora | 36+ | Basic | Dev environments |
| macOS | 12+ | Basic | Dev environments only |
| FreeBSD | 13+ | Basic | Limited testing |
| Windows | 10, Server 2016+ | Experimental | Limited functionality |

### Chef

- Chef Infra Client 18.0 or later (tested with 18.2, 18.3)
- Chef Workstation 23.7 or later (for development)

### Cookbooks

- `ark` (version ~> 5.0) - Used for installing HBase from binary releases

## Features

- Installs and configures HBase in standalone or distributed mode
- Supports HBase Master, RegionServer, and Backup Master roles
- Supports optional REST and Thrift services
- Full Kerberos security integration
- Support for metrics collection (Prometheus, Graphite)
- Advanced tuning parameters
- Comprehensive configuration options via attributes
- Modern custom resources for service and configuration management
- Integration with Hadoop HDFS (for rootdir)
- Docker-based testing infrastructure
- Test-driven development with ChefSpec and InSpec

## Usage

### Using with Policyfiles (Recommended)

Policyfiles provide a way to manage cookbook dependencies and configuration in a single file. This is the recommended approach for Chef Infra Client 18+.

#### Basic Policyfile Example

```ruby
# Policyfile.rb
name 'hbase_policy'
default_source :supermarket
run_list 'hbase::default'

# Lock version
cookbook 'hbase', '= 1.2.0', :git => 'https://github.com/thomasvincent/chef-hbase-cookbook.git'

# Override attributes
default['hbase']['config']['hbase.cluster.distributed'] = true
default['hbase']['config']['hbase.rootdir'] = 'hdfs://namenode:8020/hbase'
default['hbase']['config']['hbase.zookeeper.quorum'] = 'zk1,zk2,zk3'
default['hbase']['topology']['role'] = 'master'
```

#### Using Named Run Lists

This cookbook includes named run lists in the Policyfile to simplify role-specific deployments:

```ruby
# Policyfile.rb for HBase Master node
name 'hbase_master_policy'
default_source :supermarket

# Use the named run list for master
named_run_list :master

cookbook 'hbase', '= 1.2.0', :git => 'https://github.com/thomasvincent/chef-hbase-cookbook.git'

default['hbase']['config']['hbase.cluster.distributed'] = true
default['hbase']['config']['hbase.rootdir'] = 'hdfs://namenode:8020/hbase'
default['hbase']['config']['hbase.zookeeper.quorum'] = 'zk1,zk2,zk3'
```

#### Environment-Specific Policyfiles

For multi-environment deployments:

```ruby
# dev_hbase_policy.rb
name 'dev_hbase_policy'
default_source :supermarket
run_list 'hbase::default'

cookbook 'hbase', '= 1.2.0', :git => 'https://github.com/thomasvincent/chef-hbase-cookbook.git'

# Development environment settings
default['hbase']['config']['hbase.cluster.distributed'] = true
default['hbase']['config']['hbase.rootdir'] = 'hdfs://dev-namenode:8020/hbase'
default['hbase']['config']['hbase.zookeeper.quorum'] = 'dev-zk1,dev-zk2,dev-zk3'
default['hbase']['java_opts'] = '-Xmx1024m -XX:+UseG1GC'  # Less memory for dev
```

#### Working with Policyfiles

Install the policy and related cookbooks:

```bash
# Install dependencies
chef install Policyfile.rb

# Export for use with chef-solo or chef-client -z (local mode)
chef export Policyfile.rb ./export

# Push to Chef Infra Server for production use
chef push production Policyfile.rb

# Update a policy with latest dependencies
chef update Policyfile.rb
```

#### Using Policyfiles with Kitchen

For testing with Test Kitchen, configure your `.kitchen.yml`:

```yaml
provisioner:
  name: chef_zero
  policyfile: Policyfile.rb
  chef_license: accept-silent
```

### Basic standalone HBase

Include `hbase` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[hbase::default]"
  ]
}
```

This will install HBase in standalone mode using default settings.

### Distributed Mode

To run HBase in distributed mode with masters and region servers:

```ruby
# Master node
node['hbase']['config']['hbase.cluster.distributed'] = true
node['hbase']['config']['hbase.rootdir'] = 'hdfs://namenode:8020/hbase'
node['hbase']['config']['hbase.zookeeper.quorum'] = 'zk1,zk2,zk3'
node['hbase']['topology']['role'] = 'master'
node['hbase']['topology']['regionservers'] = ['rs1.example.com', 'rs2.example.com', 'rs3.example.com']

# RegionServer nodes
node['hbase']['config']['hbase.cluster.distributed'] = true
node['hbase']['config']['hbase.rootdir'] = 'hdfs://namenode:8020/hbase'
node['hbase']['config']['hbase.zookeeper.quorum'] = 'zk1,zk2,zk3'
node['hbase']['topology']['role'] = 'regionserver'
```

### Enabling Thrift and REST Servers

```ruby
node['hbase']['services']['thrift']['enabled'] = true
node['hbase']['services']['thrift']['config'] = {
  'hbase.thrift.info.port' => 9095,
  'hbase.thrift.port' => 9090
}

node['hbase']['services']['rest']['enabled'] = true
node['hbase']['services']['rest']['config'] = {
  'hbase.rest.info.port' => 8085,
  'hbase.rest.port' => 8080
}
```

### Configuring Kerberos Security

```ruby
node['hbase']['security']['authentication'] = 'kerberos'
node['hbase']['security']['authorization'] = true
node['hbase']['security']['kerberos']['principal'] = 'hbase/_HOST'
node['hbase']['security']['kerberos']['keytab'] = '/etc/hbase/conf/hbase.keytab'
node['hbase']['security']['kerberos']['realm'] = 'EXAMPLE.COM'

# Add these to hbase-site.xml
node['hbase']['config']['hbase.security.authentication'] = 'kerberos'
node['hbase']['config']['hbase.security.authorization'] = true
node['hbase']['config']['hbase.master.kerberos.principal'] = 'hbase/_HOST@EXAMPLE.COM'
node['hbase']['config']['hbase.regionserver.kerberos.principal'] = 'hbase/_HOST@EXAMPLE.COM'
```

### Metrics Collection

```ruby
# Enable Prometheus metrics
node['hbase']['metrics']['enabled'] = true
node['hbase']['metrics']['provider'] = 'prometheus'
node['hbase']['metrics']['prometheus']['port'] = 9090

# Or Graphite metrics
node['hbase']['metrics']['enabled'] = true
node['hbase']['metrics']['provider'] = 'graphite'
node['hbase']['metrics']['graphite']['host'] = 'metrics.example.com'
node['hbase']['metrics']['graphite']['port'] = 2003
node['hbase']['metrics']['graphite']['prefix'] = 'prod.hbase'
```

### Java Compatibility

This cookbook includes a dedicated recipe for handling Java compatibility. HBase officially supports Java 8, with preliminary support for Java 11 and Java 17.

```ruby
# Set Java version (8, 11, or 17)
node['hbase']['java']['version'] = '11'

# Optionally, set a custom JAVA_HOME (if not set, it will be auto-detected)
node['hbase']['java_home'] = '/path/to/java/home'
```

The cookbook automatically:
1. Detects appropriate Java home location based on platform and Java version
2. Installs the appropriate JDK package for your platform
3. Configures JAVA_HOME and adds it to the system environment
4. Verifies Java installation before proceeding with HBase installation

Supported Java versions per HBase version:
- HBase 2.5.x: Java 8 (officially), Java 11, 17 (preliminary)
- HBase 2.4.x: Java 8 (officially), Java 11 (preliminary)
- HBase 2.3.x: Java 8 only

### Advanced JVM Configuration

```ruby
node['hbase']['java_opts'] = '-Xmx4096m -Xms1024m -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200'
```

### Custom Resources

This cookbook provides two custom resources:

#### hbase_config

Creates a configuration file:

```ruby
hbase_config '/etc/hbase/conf/my-custom-site.xml' do
  user 'hbase'
  group 'hbase'
  variables({
    'custom.property.one' => 'value1',
    'custom.property.two' => 'value2'
  })
  config_type 'xml'
  restart_services ['master', 'regionserver']
  action :create
end
```

#### hbase_service

Creates and manages an HBase service:

```ruby
hbase_service 'master' do
  java_opts '-Xmx2048m'
  service_config {
    'hbase.master.info.port' => 16011
  }
  restart_on_config_change true
  action [:create, :enable, :start]
end
```

## Testing

This cookbook uses Test Kitchen with Docker for integration testing.

### Testing with Dokken

The fastest way to test is using the dokken driver, which is specifically designed for Test Kitchen with Docker:

```bash
# Run all tests using dokken
KITCHEN_YAML=kitchen.docker.yml bundle exec kitchen test

# Test a specific platform
KITCHEN_YAML=kitchen.docker.yml bundle exec kitchen test ubuntu-20-04

# Test a specific instance
KITCHEN_YAML=kitchen.docker.yml bundle exec kitchen test ubuntu-20-04-default
```

### Using the Test Script

For easier testing, especially when you don't have Ruby installed locally, use the provided test script:

```bash
# Run the test script (requires Docker)
./test-docker.sh
```

The test script will:
1. Spin up a Docker container with all required dependencies
2. Run the tests on the specified platforms (default: Ubuntu 20.04)
3. Clean up after testing

You can modify the script to test additional platforms and suites.

### Using Rake Tasks for Testing

The cookbook includes Rake tasks to simplify testing:

```bash
# Run all tests (style, unit, integration)
bundle exec rake test

# Run only style checks
bundle exec rake style

# Run only unit tests
bundle exec rake spec

# Run integration tests with Docker
bundle exec rake integration:docker

# Test a specific platform
bundle exec rake integration:docker_platform[ubuntu-20-04]

# Test a specific suite
bundle exec rake integration:suite[distributed]
```

## CI/CD

This cookbook uses modern GitHub Actions for CI/CD, with comprehensive workflows defined in `.github/workflows/`:

### CI Pipeline (ci.yml)

The CI pipeline runs on every push and pull request to main/master branches:

1. **Linting Stage**:
   - Runs Cookstyle with detailed cop names
   - Fast-failing to catch style issues early
   - Uses Ruby 3.2 for modern compatibility

2. **Unit Testing Stage**:
   - Runs ChefSpec tests on all recipes and resources
   - Generates test reports in JUnit format for easier troubleshooting
   - Test artifacts are stored for later analysis

3. **Integration Testing Stage**:
   - Matrix testing across multiple platforms (Ubuntu, Debian, RHEL, etc.)
   - Matrix testing across multiple suite configurations
   - Runs on dokken-based containers for speed and consistency
   - Full Chef Infra Client converge with idempotency verification

4. **Chef Version Verification**:
   - Verifies compatibility across multiple Chef versions (18.0, 18.2, 18.3)
   - Ensures backward compatibility with supported Chef releases
   - Fast, parallel execution using GitHub Actions runners

### Pre-commit Checks (pre-commit.yml)

The pre-commit workflow enforces code quality standards:

- Git hooks for ensuring clean commits
- Enhanced Ruby and Chef syntax verification
- Markdown linting for documentation quality
- Deep verification of file modes and permissions
- YAML and JSON validation

### Scheduled Testing

Weekly tests run to catch compatibility issues with dependencies:

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday at midnight UTC
```

### Test Matrix Coverage

The integration tests cover an expanded set of platforms:

| Category | Platforms |
|----------|-----------|
| Ubuntu | 18.04, 20.04, 22.04 |
| Debian | 10, 11 |
| RHEL-compatible | CentOS 7, AlmaLinux/Rocky 8, 9 |
| Amazon Linux | 2, 2023 |
| SUSE | openSUSE Leap 15 |
| Fedora | Latest |

### Continuous Testing Dashboard

Test results are available in the GitHub Actions interface with:
- Detailed test reporting
- Artifact storage for logs and outputs
- Failure analysis and quick debugging

### Local CI Testing

You can run the same CI pipeline locally:

```bash
# Run linting checks
bundle exec cookstyle --display-cop-names

# Run unit tests
bundle exec rspec spec/unit

# Run integration tests for a specific platform
KITCHEN_YAML=kitchen.yml bundle exec kitchen test default-ubuntu-2204
```

## Attributes

See `attributes/default.rb` for a comprehensive list of configurable attributes.

Key attributes include:

```ruby
# Version and installation
default['hbase']['version'] = '2.5.11'
default['hbase']['install_dir'] = '/opt/hbase'
default['hbase']['conf_dir'] = '/etc/hbase/conf'

# Java options
default['hbase']['java']['version'] = '11'
default['hbase']['java_opts'] = '-Xmx1024m -XX:+UseG1GC'

# Topology settings
default['hbase']['topology']['role'] = nil # 'master', 'regionserver', etc.

# Core configuration
default['hbase']['config']['hbase.rootdir'] = 'file:///var/hbase'
default['hbase']['config']['hbase.cluster.distributed'] = false
```

## Version Compatibility Matrix

| HBase Version | Hadoop Version | Java Compatibility     | Chef Version |
|---------------|----------------|------------------------|--------------|
| 2.5.x         | 3.x            | 8 (official), 11, 17   | >= 18.0      |
| 2.4.x         | 2.x, 3.x       | 8 (official), 11       | >= 18.0      |
| 2.3.x         | 2.x            | 8 only                 | >= 18.0      |

## Development

This cookbook follows modern Chef development practices with a focus on testing, CI integration, and comprehensive documentation.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-new-feature`)
3. Write tests for your changes (ChefSpec for unit, InSpec for integration)
4. Implement your changes
5. Run the pre-commit hooks and tests to ensure they pass
6. Submit a Pull Request with a comprehensive description
7. Ensure the CI pipeline passes

### Setting Up Your Development Environment

#### Option 1: Using Chef Workstation (Recommended)

```bash
# Install Chef Workstation from https://downloads.chef.io/tools/workstation
# Then clone the repository
git clone https://github.com/thomasvincent/chef-hbase-cookbook.git
cd chef-hbase-cookbook

# Install dependencies
bundle install

# Install pre-commit hooks
pre-commit install

# Initialize development environment
chef generate repo-config
```

#### Option 2: Using Docker Development Container

```bash
# Using the provided Dockerfile.dev
docker build -f Dockerfile.dev -t hbase-cookbook-dev .
docker run -it --rm -v $(pwd):/cookbook hbase-cookbook-dev

# Inside the container
cd /cookbook
bundle install
pre-commit install
```

#### Option 3: Using asdf for Ruby Version Management

```bash
# Install asdf - https://asdf-vm.com/
asdf plugin add ruby
asdf install ruby 3.2.0
asdf local ruby 3.2.0

# Install dependencies
gem install bundler
bundle install

# Install pre-commit hooks
pre-commit install
```

### Running Tests

```bash
# Run all tests
bundle exec rake test

# Run style checks
bundle exec cookstyle

# Run unit tests with detailed output
bundle exec rspec spec/unit --format documentation

# Run kitchen tests with a specific platform
KITCHEN_YAML=kitchen.yml bundle exec kitchen test default-ubuntu-2204
```

### Using Test-Driven Development

For best results, follow this TDD workflow:

1. Write a failing ChefSpec test for the code change
2. Implement the change in resources or recipes
3. Verify the ChefSpec test passes
4. Write InSpec tests for integration validation
5. Run Test Kitchen to verify the change works across platforms

### Commit Guidelines

This project uses the Conventional Commits specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Examples:
- `feat(resources): add new hbase_user resource`
- `fix(config): correct ZooKeeper quorum configuration`
- `docs(readme): update installation instructions`
- `chore(deps): update ark dependency`

### Generating Documentation

```bash
# Generate markdown documentation from code
bundle exec yard doc --plugin chef

# Create a README TOC
npx markdown-toc -i README.md
```

### Cookbook Release Process

1. Update version in metadata.rb
2. Update CHANGELOG.md following Keep a Changelog format
3. Commit with message "release: X.Y.Z"
4. Tag the release `git tag vX.Y.Z`
5. Push to GitHub `git push origin main --tags`

## License

Licensed under the Apache License, Version 2.0.