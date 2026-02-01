#
# Cookbook:: hbase
# Recipe:: thrift
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Setup HBase Thrift service
log 'hbase_thrift_setup' do
  message lazy { "Setting up HBase Thrift Server on #{node['fqdn']}" }
  level :info
end

# Configure thrift-specific settings
thrift_config = node['hbase']['services']['thrift']['config'] || {}
node.default['hbase']['service_mapping']['thrift']['config'] = thrift_config unless node['hbase']['service_mapping']['thrift']['config']

# Create and start the thrift service
hbase_service 'thrift' do
  restart_on_config_change true
  service_config node['hbase']['service_mapping']['thrift']['config']
  action [:create, :enable, :start]
end
