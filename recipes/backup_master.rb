#
# Cookbook:: hbase
# Recipe:: backup_master
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Setup HBase Backup Master service
Chef::Log.info("Setting up HBase Backup Master on #{node['fqdn']}")

# Create and start the master service in backup mode
# Technically, the service is the same as master, but this node
# will be listed in the backup-masters file
hbase_service 'master' do
  restart_on_config_change true
  service_config node['hbase']['service_mapping']['master']['config'] if node['hbase']['service_mapping']['master']['config']
  action [:create, :enable, :start]
end
