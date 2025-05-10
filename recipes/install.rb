#
# Cookbook:: hbase
# Recipe:: install
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Create required directories
%w(
  install_dir
  conf_dir
  log_dir
  pid_dir
).each do |dir|
  directory node['hbase'][dir] do
    owner node['hbase']['user']
    group node['hbase']['group']
    mode '0755'
    recursive true
    action :create
  end
end

# Create data directories
directory ::File.dirname(node['hbase']['config']['hbase.rootdir'].sub('file://', '')) do
  owner node['hbase']['user']
  group node['hbase']['group']
  mode '0755'
  recursive true
  action :create
  not_if { node['hbase']['config']['hbase.rootdir'].start_with?('hdfs://') }
end

directory node['hbase']['config']['hbase.zookeeper.property.dataDir'] do
  owner node['hbase']['user']
  group node['hbase']['group']
  mode '0755'
  recursive true
  action :create
end

case node['hbase']['install']['method']
when 'binary'
  # Download and extract HBase using the ark cookbook
  ark 'hbase' do
    url "#{node['hbase']['mirror']}/#{node['hbase']['version']}/hbase-#{node['hbase']['version']}-bin.tar.gz"
    version node['hbase']['version']
    checksum node['hbase']['checksum'] if node['hbase']['checksum']
    path ::File.dirname(node['hbase']['install_dir'])
    home_dir node['hbase']['install_dir']
    owner node['hbase']['user']
    group node['hbase']['group']
    action :install
  end

  # Create symlink to make it easier to reference
  link "#{node['hbase']['install_dir']}/current" do
    to "#{node['hbase']['install_dir']}/hbase-#{node['hbase']['version']}"
    owner node['hbase']['user']
    group node['hbase']['group']
  end

when 'package'
  # Install from system packages
  node['hbase']['install']['packages'].each do |pkg|
    package pkg do
      action :install
    end
  end
end