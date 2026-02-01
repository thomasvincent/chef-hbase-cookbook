#
# Cookbook:: hbase
# Recipe:: java
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Determine Java home directory if not explicitly set
# All supported platforms use Java 11+ which has consistent paths
if node['hbase']['java_home'].nil?
  jdk_version = node['hbase']['java']['version']

  case node['platform_family']
  when 'debian'
    node.default['hbase']['java_home'] = "/usr/lib/jvm/java-#{jdk_version}-openjdk-amd64"
  when 'rhel', 'fedora', 'amazon'
    # RHEL 9+, Rocky 9+, and Amazon Linux 2023 use consistent paths
    node.default['hbase']['java_home'] = "/usr/lib/jvm/java-#{jdk_version}-openjdk"
  else
    log 'java_unsupported_platform' do
      message lazy { "Unsupported platform family: #{node['platform_family']}. Setting default Java home." }
      level :warn
    end
    node.default['hbase']['java_home'] = "/usr/lib/jvm/java-#{jdk_version}-openjdk"
  end
end

# Install the appropriate Java package based on platform
# All supported platforms (Ubuntu 22.04+, Debian 12+, RHEL 9+, Amazon 2023+) use standard package managers
jdk_version = node['hbase']['java']['version']

case node['platform_family']
when 'debian'
  package "openjdk-#{jdk_version}-jdk" do
    action :install
  end
when 'rhel', 'fedora', 'amazon'
  # RHEL 9+, Rocky 9+, and Amazon Linux 2023 all use dnf with standard package names
  package "java-#{jdk_version}-openjdk-devel" do
    action :install
  end
else
  log 'java_install_unsupported' do
    message lazy { "Unsupported platform family for Java installation: #{node['platform_family']}. Please install Java manually." }
    level :warn
  end
end

# Verify Java installation
ruby_block 'verify_java_installation' do
  block do
    cmd = Mixlib::ShellOut.new('java -version')
    cmd.run_command
    if cmd.error?
      raise("Java installation failed: #{cmd.stderr}")
    else
      Chef.logger.info("Java installation verified: #{cmd.stderr}")
    end
  end
  action :run
end

# Set JAVA_HOME in environment if needed
file '/etc/profile.d/java_home.sh' do
  content "export JAVA_HOME=#{node['hbase']['java_home']}\n"
  mode '0755'
  action :create
end
