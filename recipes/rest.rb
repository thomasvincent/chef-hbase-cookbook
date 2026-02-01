#
# Cookbook:: hbase
# Recipe:: rest
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Setup HBase REST service
log 'hbase_rest_setup' do
  message lazy { "Setting up HBase REST Server on #{node['fqdn']}" }
  level :info
end

# Configure REST-specific settings
rest_config = node['hbase']['services']['rest']['config'] || {}
node.default['hbase']['service_mapping']['rest']['config'] = rest_config unless node['hbase']['service_mapping']['rest']['config']

# Create and start the REST service
hbase_service 'rest' do
  restart_on_config_change true
  service_config node['hbase']['service_mapping']['rest']['config']
  action [:create, :enable, :start]
end
