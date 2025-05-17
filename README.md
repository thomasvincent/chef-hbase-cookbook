# HBase Cookbook

[![CI](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/ci.yml/badge.svg)](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/ci.yml)
[![pre-commit](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/pre-commit.yml)

This cookbook installs and configures Apache HBase - the Hadoop database, a distributed, scalable, big data store.

## Requirements

### Platforms

This cookbook is tested on the following platforms using Test Kitchen with the [kitchen-dokken](https://github.com/test-kitchen/kitchen-dokken) driver:

- Ubuntu 20.04, 22.04
- Debian 11
- AlmaLinux/RHEL 8, 9
- Amazon Linux 2, 2023
- Fedora 36+

Other Linux distributions may work but are not officially supported or tested.

### Chef

- Chef 18.0 or later

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

Policyfiles provide a way to manage cookbook dependencies and configuration in a single file:

```ruby
# Policyfile.rb
name 'hbase_policy'
default_source :supermarket
run_list 'hbase::default'

# Lock version
cookbook 'hbase', '= 1.1.0', :git => 'https://github.com/thomasvincent/chef-hbase-cookbook.git'

# Override attributes
default['hbase']['config']['hbase.cluster.distributed'] = true
default['hbase']['config']['hbase.rootdir'] = 'hdfs://namenode:8020/hbase'
default['hbase']['config']['hbase.zookeeper.quorum'] = 'zk1,zk2,zk3'
default['hbase']['topology']['role'] = 'master'
```

Install the policy and related cookbooks:

```bash
chef install Policyfile.rb
```

Push the policy to the Chef server (if using Chef Infra Server):

```bash
chef push production Policyfile.rb
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

This cookbook uses GitHub Actions for CI/CD, with workflows defined in `.github/workflows/`:

1. **ci.yml**: 
   - Linting: Runs Cookstyle to check code style
   - Unit Testing: Runs ChefSpec tests 
   - Integration Testing: Runs Test Kitchen tests on multiple platforms using Docker

2. **pre-commit.yml**:
   - Runs pre-commit hooks to enforce code quality
   - Checks for merge conflicts, trailing whitespace, YAML validity
   - Runs shellcheck on shell scripts
   - Runs cookstyle on Ruby files

The integration tests cover the following platforms:
- Ubuntu 20.04 and 22.04
- Debian 11
- AlmaLinux 8, 9
- Amazon Linux 2, 2023
- Fedora 36+

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

1. Fork the repository
2. Create a feature branch
3. Add tests for your changes
4. Make your changes
5. Run the tests to ensure they pass
6. Submit a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/thomasvincent/chef-hbase-cookbook.git
cd chef-hbase-cookbook

# Install dependencies
bundle install

# Install pre-commit hooks
pre-commit install

# Run tests
bundle exec rake style
bundle exec rake spec
KITCHEN_YAML=kitchen.docker.yml bundle exec kitchen test
```

## License

Licensed under the Apache License, Version 2.0.