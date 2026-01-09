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
include_recipe 'hbase::java'
include_recipe 'hbase::user'
include_recipe 'hbase::install'
include_recipe 'hbase::config'

# Configure Kerberos security if enabled
if node['hbase']['security']['authentication'] == 'kerberos'
  Chef::Log.info('Configuring HBase with Kerberos authentication')

  # Ensure Kerberos keytab exists and has correct permissions
  file node['hbase']['security']['kerberos']['keytab'] do
    owner node['hbase']['user']
    group node['hbase']['group']
    mode '0400'
    action :create
    only_if { ::File.exist?(node['hbase']['security']['kerberos']['keytab']) }
  end

  # Set Kerberos-specific configuration properties
  node.default['hbase']['config']['hbase.security.authentication'] = 'kerberos'
  node.default['hbase']['config']['hbase.security.authorization'] = node['hbase']['security']['authorization']
  node.default['hbase']['config']['hbase.master.kerberos.principal'] = node['hbase']['security']['kerberos']['server_principal']
  node.default['hbase']['config']['hbase.regionserver.kerberos.principal'] = node['hbase']['security']['kerberos']['regionserver_principal']
  node.default['hbase']['config']['hbase.master.keytab.file'] = node['hbase']['security']['kerberos']['keytab']
  node.default['hbase']['config']['hbase.regionserver.keytab.file'] = node['hbase']['security']['kerberos']['keytab']
  node.default['hbase']['config']['hbase.rpc.protection'] = 'privacy'
  node.default['hbase']['config']['hbase.coprocessor.master.classes'] = 'org.apache.hadoop.hbase.security.access.AccessController'
  node.default['hbase']['config']['hbase.coprocessor.region.classes'] = 'org.apache.hadoop.hbase.security.token.TokenProvider,org.apache.hadoop.hbase.security.access.AccessController'
end

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
