#
# Cookbook:: hbase
# Recipe:: master
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Setup HBase Master service
log 'hbase_master_setup' do
  message lazy { "Setting up HBase Master on #{node['fqdn']}" }
  level :info
end

# Configure master-specific settings if needed
master_config = node['hbase']['service_mapping']['master']['config'] || {}
node.default['hbase']['service_mapping']['master']['config'] = master_config if master_config.empty?

# Create and start the master service
hbase_service 'master' do
  restart_on_config_change true
  service_config node['hbase']['service_mapping']['master']['config']
  action [:create, :enable, :start]
end
