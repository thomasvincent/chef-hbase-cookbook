#
# Cookbook:: hbase
# Recipe:: regionserver
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Setup HBase RegionServer service
Chef::Log.info("Setting up HBase RegionServer on #{node['fqdn']}")

# Configure regionserver-specific settings if needed
regionserver_config = {}
node['hbase']['service_mapping']['regionserver']['config'] ||= regionserver_config

# Create and start the regionserver service
hbase_service 'regionserver' do
  restart_on_config_change true
  service_config node['hbase']['service_mapping']['regionserver']['config']
  action [:create, :enable, :start]
end
