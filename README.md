# HBase Cookbook

[![CI](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/ci.yml/badge.svg)](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/ci.yml)

This cookbook installs and configures Apache HBase - the Hadoop database, a distributed, scalable, big data store.

## Requirements

### Platforms
- Ubuntu 20.04, 22.04
- Debian 11+
- AlmaLinux/RHEL 8, 9
- Amazon Linux 2
- Fedora 36+

### Chef
- Chef 18.0+

### Cookbooks
- `ark` - Used for installing HBase from binary releases

## Features

- Installs and configures HBase 2.x in standalone or distributed mode
- Supports HBase Master, RegionServer, and Backup Master roles
- Supports optional REST and Thrift services
- Full Kerberos security integration
- Support for metrics collection (Prometheus, Graphite)
- Advanced tuning parameters
- Comprehensive configuration options via attributes
- Modern custom resources for service and configuration management
- Integration with Hadoop HDFS (for rootdir)
- Docker-based testing infrastructure

## Usage

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

## Security

### Kerberos Authentication

This cookbook provides full support for Kerberos authentication, which is the recommended security mechanism for production HBase deployments. When Kerberos is enabled, the cookbook automatically configures:

- HBase Master and RegionServer Kerberos principals
- Keytab file permissions and ownership
- RPC protection settings
- Access control coprocessors

#### Prerequisites

Before enabling Kerberos authentication, ensure:

1. A working Kerberos KDC (Key Distribution Center) is available
2. Kerberos client packages are installed on all HBase nodes
3. Service principals are created for HBase (e.g., `hbase/_HOST@REALM`)
4. Keytab files are distributed to all HBase nodes

#### Configuration

To enable Kerberos authentication:

```ruby
# Enable Kerberos authentication
node['hbase']['security']['authentication'] = 'kerberos'
node['hbase']['security']['authorization'] = true

# Configure Kerberos settings
node['hbase']['security']['kerberos']['principal'] = 'hbase/_HOST'
node['hbase']['security']['kerberos']['keytab'] = '/etc/hbase/conf/hbase.keytab'
node['hbase']['security']['kerberos']['realm'] = 'EXAMPLE.COM'
node['hbase']['security']['kerberos']['server_principal'] = 'hbase/_HOST@EXAMPLE.COM'
node['hbase']['security']['kerberos']['regionserver_principal'] = 'hbase/_HOST@EXAMPLE.COM'
```

The cookbook will automatically set the following hbase-site.xml properties when Kerberos is enabled:

| Property | Value |
|----------|-------|
| `hbase.security.authentication` | `kerberos` |
| `hbase.security.authorization` | `true` (if authorization enabled) |
| `hbase.master.kerberos.principal` | Configured server principal |
| `hbase.regionserver.kerberos.principal` | Configured regionserver principal |
| `hbase.master.keytab.file` | Configured keytab path |
| `hbase.regionserver.keytab.file` | Configured keytab path |
| `hbase.rpc.protection` | `privacy` |
| `hbase.coprocessor.master.classes` | `AccessController` |
| `hbase.coprocessor.region.classes` | `TokenProvider,AccessController` |

#### Security Best Practices

1. **Keytab Protection**: Keytab files are automatically set to mode `0400` (read-only by owner)
2. **Network Security**: Use firewall rules to restrict access to HBase ports
3. **Audit Logging**: Enable HBase audit logging for security monitoring
4. **Regular Rotation**: Implement regular keytab rotation procedures

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

This cookbook includes a dedicated recipe for handling Java compatibility. HBase 2.4.0 officially supports Java 8, with preliminary support for Java 11.

```ruby
# Set Java version (8 or 11)
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

## Recipes

### default
Main recipe that orchestrates the HBase installation. Includes user creation, installation, configuration, and service setup.

### install
Downloads and installs HBase from Apache mirrors using the ark cookbook.

### config
Configures HBase settings including hbase-site.xml, hbase-env.sh, and topology files (regionservers, backup-masters).

### user
Creates the HBase system user and group with appropriate permissions.

### java
Handles Java installation and configuration, ensuring compatible Java version is available.

### master
Configures and starts the HBase Master service.

### regionserver
Configures and starts the HBase RegionServer service.

### backup_master
Configures and starts the HBase Backup Master service.

### rest
Configures and starts the HBase REST API service.

### thrift
Configures and starts the HBase Thrift API service.

### limits
Configures system limits (ulimits) for the HBase user.

## Testing

This cookbook uses Test Kitchen with Docker for integration testing.

### Testing with Dokken

Run Test Kitchen using the bundled configuration:

```bash
# Run all tests using dokken
bundle exec kitchen test

# Test a specific platform
bundle exec kitchen test ubuntu-20-04

# Test a specific instance
bundle exec kitchen test ubuntu-20-04-default
```

### Using Rake Tasks for Testing

The cookbook includes Rake tasks to simplify testing:

```bash
# Run all tests (style, unit, integration)
bundle exec rake test

# Run only style checks
bundle exec rake style

# Run only unit tests
bundle exec rake spec

# Run integration tests
bundle exec rake integration:kitchen

# Test a specific platform
bundle exec rake integration:platform[ubuntu-20-04]

# Test a specific suite
bundle exec rake integration:suite[distributed]

# Test a specific instance
bundle exec rake integration:instance[ubuntu-20-04-default]
```

## CI/CD

This cookbook uses GitHub Actions for CI/CD, with workflows defined in `.github/workflows/ci.yml`:

1. **Linting**: Runs Cookstyle to check code style
2. **Unit Testing**: Runs ChefSpec tests 
3. **Integration Testing**: Runs Test Kitchen tests on multiple platforms using Docker:
   - Ubuntu 20.04 and 22.04
   - AlmaLinux 8
   - Amazon Linux 2

## Attributes

See `attributes/default.rb` for a comprehensive list of configurable attributes.

## Development

This cookbook uses a comprehensive testing and linting workflow:

```bash
# Install dependencies
bundle install

# Run all tests (style, unit, integration)
bundle exec rake test

# Run only style checks (cookstyle)
bundle exec rake style

# Run only unit tests (ChefSpec)
bundle exec rake spec

# Run integration tests (Test Kitchen)
bundle exec kitchen test
```

## Contributing

1. Fork the repository on GitHub
2. Create a feature branch (`git checkout -b feature/my-new-feature`)
3. Write tests for your changes
4. Make your changes
5. Run the test suite to ensure all tests pass
6. Commit your changes (`git commit -am 'Add new feature'`)
7. Push to the branch (`git push origin feature/my-new-feature`)
8. Create a Pull Request

Please ensure:
- All tests pass before submitting PR
- Code follows Cookstyle guidelines
- New features include appropriate tests
- Documentation is updated for any new attributes or recipes

## License

Licensed under the Apache License, Version 2.0.
