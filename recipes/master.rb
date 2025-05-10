#
# Cookbook:: hbase
# Recipe:: master
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Setup HBase Master service
Chef::Log.info("Setting up HBase Master on #{node['fqdn']}")

# Configure master-specific settings if needed
master_config = {}
node['hbase']['service_mapping']['master']['config'] ||= master_config

# Create and start the master service
hbase_service 'master' do
  restart_on_config_change true
  service_config node['hbase']['service_mapping']['master']['config']
  action [:create, :enable, :start]
end