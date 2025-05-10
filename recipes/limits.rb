#
# Cookbook:: hbase
# Recipe:: limits
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Set system limits for the HBase user

template '/etc/security/limits.d/hbase.conf' do
  source 'limits.conf.erb'
  mode '0644'
  variables(
    user: node['hbase']['user'],
    nofile: node['hbase']['limits']['nofile'],
    nproc: node['hbase']['limits']['nproc']
  )
end