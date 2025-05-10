# HBase Cookbook

[![CI](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/ci.yml/badge.svg)](https://github.com/thomasvincent/chef-hbase-cookbook/actions/workflows/ci.yml)

This cookbook installs and configures Apache HBase - the Hadoop database, a distributed, scalable, big data store.

## Requirements

### Platforms
- Ubuntu 20.04+
- Debian 11+
- CentOS/RHEL 8+
- Amazon Linux 2

### Chef
- Chef 16.0+

### Cookbooks
- `java` - HBase requires Java
- `ark` - Used for installing HBase from binary releases

## Features

- Installs and configures HBase in standalone or distributed mode
- Supports HBase Master, RegionServer, and Backup Master roles
- Supports optional REST and Thrift services
- Full Kerberos security integration
- Support for custom JVM configuration
- Comprehensive configuration options via attributes
- Resource-based configuration for cleaner, reusable code
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

This cookbook uses Test Kitchen with Docker for integration testing:

```bash
# Run all tests
bundle exec rake test

# Run style checks only
bundle exec rake style

# Run unit tests only
bundle exec rake spec

# Run integration tests
bundle exec rake integration:docker
```

### Docker Container Testing

For testing in an isolated environment, you can use the provided Docker container:

```bash
# Build the container
docker build -t hbase-test -f Dockerfile.kitchen .

# Run tests inside the container
docker run --rm hbase-test
```

## CI/CD

This cookbook uses GitHub Actions for CI/CD, with workflows defined in `.github/workflows/ci.yml`:

1. **Linting**: Runs Cookstyle to check code style
2. **Unit Testing**: Runs ChefSpec tests
3. **Docker Testing**: Tests Docker container build

## Attributes

See `attributes/default.rb` for a comprehensive list of configurable attributes.

## Development

1. Fork the repository
2. Create a feature branch
3. Add tests for your changes
4. Make your changes
5. Run the tests to ensure they pass
6. Submit a Pull Request

## License

Licensed under the Apache License, Version 2.0.