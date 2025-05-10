#
# Cookbook:: hbase
# Recipe:: default
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

Chef::Log.info('Starting HBase installation')

# Include helper methods
extend HBase::Helper

# Include dependent recipes
include_recipe 'hbase::user'
include_recipe 'hbase::install'
include_recipe 'hbase::config'

# Setup appropriate services based on node role
case node['hbase']['topology']['role']
when 'master'
  include_recipe 'hbase::master'
when 'regionserver'
  include_recipe 'hbase::regionserver'
when 'backup_master'
  include_recipe 'hbase::backup_master'
else
  # Standalone mode or custom configuration
  Chef::Log.info('Setting up HBase in standalone mode or custom configuration')
  
  # Always create and start master service in standalone mode
  hbase_service 'master' do
    restart_on_config_change true
    service_config node['hbase']['service_mapping']['master']['config'] if node['hbase']['service_mapping']['master']['config']
    action [:create, :enable, :start]
  end
end

# Setup optional services if enabled
if node['hbase']['services']['thrift']['enabled']
  include_recipe 'hbase::thrift'
end

if node['hbase']['services']['rest']['enabled']
  include_recipe 'hbase::rest'
end

Chef::Log.info('HBase installation completed successfully')