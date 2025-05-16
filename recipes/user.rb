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

# System limits are configured in the limits recipe
include_recipe 'hbase::limits'