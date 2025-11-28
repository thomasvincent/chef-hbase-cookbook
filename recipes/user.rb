#
# Cookbook:: hbase
# Recipe:: user
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Create HBase group
group node['hbase']['group'] do
  gid node['hbase']['gid']
  system true
  action :create
end

# Create HBase user
user node['hbase']['user'] do
  comment 'HBase Service Account'
  uid node['hbase']['uid']
  gid node['hbase']['group']
  home node['hbase']['install_dir']
  shell '/bin/bash'
  system true
  action :create
end

# Configure system limits for the HBase user
template '/etc/security/limits.d/hbase.conf' do
  source 'limits.conf.erb'
  mode '0644'
  variables(
    user: node['hbase']['user'],
    nofile: node['hbase']['limits']['nofile'],
    nproc: node['hbase']['limits']['nproc']
  )
end
