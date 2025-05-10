#
# Cookbook:: hbase
# Recipe:: java
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Determine Java home directory if not explicitly set
if node['hbase']['java_home'].nil?
  jdk_version = node['hbase']['java']['version']
  
  case node['platform_family']
  when 'debian'
    node.default['hbase']['java_home'] = "/usr/lib/jvm/java-#{jdk_version}-openjdk-amd64"
  when 'rhel', 'fedora', 'amazon'
    # RHEL/CentOS/Fedora/Amazon Linux
    if jdk_version.to_i >= 11
      node.default['hbase']['java_home'] = "/usr/lib/jvm/java-#{jdk_version}-openjdk"
    else
      node.default['hbase']['java_home'] = "/usr/lib/jvm/java-#{jdk_version}-openjdk-#{node['kernel']['machine']}"
    end
  else
    Chef::Log.warn("Unsupported platform family: #{node['platform_family']}. Setting default Java home.")
    node.default['hbase']['java_home'] = "/usr/lib/jvm/java-#{jdk_version}-openjdk"
  end
end

# Install the appropriate Java package based on platform and version
jdk_version = node['hbase']['java']['version']

case node['platform_family']
when 'debian'
  package "openjdk-#{jdk_version}-jdk" do
    action :install
  end
when 'rhel', 'fedora'
  package "java-#{jdk_version}-openjdk-devel" do
    action :install
  end
when 'amazon'
  if jdk_version.to_i == 8
    package 'java-1.8.0-openjdk-devel' do
      action :install
    end
  elsif jdk_version.to_i == 11
    execute 'install-java-11' do
      command 'amazon-linux-extras install java-openjdk11 -y'
      not_if 'rpm -q java-11-openjdk-devel'
    end
  else
    package "java-#{jdk_version}-openjdk-devel" do
      action :install
    end
  end
else
  Chef::Log.warn("Unsupported platform family for Java installation: #{node['platform_family']}. Please install Java manually.")
end

# Verify Java installation
ruby_block 'verify_java_installation' do
  block do
    cmd = Mixlib::ShellOut.new('java -version')
    cmd.run_command
    if cmd.error?
      Chef::Application.fatal!("Java installation failed: #{cmd.stderr}")
    else
      Chef::Log.info("Java installation verified: #{cmd.stderr}")
    end
  end
  action :create
end

# Set JAVA_HOME in environment if needed
file '/etc/profile.d/java_home.sh' do
  content "export JAVA_HOME=#{node['hbase']['java_home']}\n"
  mode '0755'
  action :create
end