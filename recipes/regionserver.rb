#
# Cookbook:: hbase
# Recipe:: regionserver
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Setup HBase RegionServer service
log 'hbase_regionserver_setup' do
  message lazy { "Setting up HBase RegionServer on #{node['fqdn']}" }
  level :info
end

# Configure regionserver-specific settings if needed
regionserver_config = node['hbase']['service_mapping']['regionserver']['config'] || {}
node.default['hbase']['service_mapping']['regionserver']['config'] = regionserver_config if regionserver_config.empty?

# Create and start the regionserver service
hbase_service 'regionserver' do
  restart_on_config_change true
  service_config node['hbase']['service_mapping']['regionserver']['config']
  action [:create, :enable, :start]
end
