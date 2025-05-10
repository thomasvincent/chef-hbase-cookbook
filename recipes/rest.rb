#
# Cookbook:: hbase
# Recipe:: rest
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Setup HBase REST service
Chef::Log.info("Setting up HBase REST Server on #{node['fqdn']}")

# Configure REST-specific settings
rest_config = node['hbase']['services']['rest']['config'] || {}
node['hbase']['service_mapping']['rest']['config'] ||= rest_config

# Create and start the REST service
hbase_service 'rest' do
  restart_on_config_change true
  service_config node['hbase']['service_mapping']['rest']['config']
  action [:create, :enable, :start]
end