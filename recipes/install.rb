#
# Cookbook:: hbase
# Recipe:: install
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Create required directories
# Note: install_dir is excluded for binary installs because the ark resource
# manages that path as a symlink. Creating it as a directory would cause EISDIR.
install_dirs = %w(conf_dir log_dir pid_dir)
install_dirs << 'install_dir' unless node['hbase']['install']['method'] == 'binary'

install_dirs.each do |dir|
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

  # The ark resource with action :install creates a symlink at home_dir
  # pointing to the versioned extraction directory, so no additional
  # symlink is needed.

when 'package'
  # Install from system packages
  node['hbase']['install']['packages'].each do |pkg|
    package pkg do
      action :install
    end
  end
end
