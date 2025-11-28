#
# Cookbook:: hbase
# Recipe:: config
#
# Copyright:: 2023 Thomas Vincent
#
# Licensed under the Apache License, Version 2.0

# Generate common configuration files using the custom resource

# hbase-site.xml - Main configuration file
hbase_config "#{node['hbase']['conf_dir']}/hbase-site.xml" do
  user node['hbase']['user']
  group node['hbase']['group']
  variables(node['hbase']['config'])
  config_type 'xml'
  use_helpers true
  action :create
end

# hbase-env.sh - Environment variables
env_vars = {
  'java_home' => node['hbase']['java_home'],
  'hbase_conf_dir' => node['hbase']['conf_dir'],
  'hbase_log_dir' => node['hbase']['log_dir'],
  'hbase_pid_dir' => node['hbase']['pid_dir'],
  'hbase_opts' => node['hbase']['java_opts'],
}

# Add Kerberos settings if authentication is kerberos
if node['hbase']['security']['authentication'] == 'kerberos'
  env_vars['hbase_opts'] = "#{env_vars['hbase_opts']} -Djava.security.auth.login.config=#{node['hbase']['conf_dir']}/jaas.conf"

  # Create jaas.conf
  template "#{node['hbase']['conf_dir']}/jaas.conf" do
    source 'jaas.conf.erb'
    owner node['hbase']['user']
    group node['hbase']['group']
    mode '0600'
    variables(
      principal: node['hbase']['security']['kerberos']['principal'],
      keytab: node['hbase']['security']['kerberos']['keytab'],
      realm: node['hbase']['security']['kerberos']['realm']
    )
    action :create
  end
end

# Add metrics configuration if enabled
if node['hbase']['metrics']['enabled']
  case node['hbase']['metrics']['provider']
  when 'prometheus'
    env_vars['hbase_opts'] = "#{env_vars['hbase_opts']} -javaagent:#{node['hbase']['install_dir']}/lib/jmx_prometheus_javaagent.jar=#{node['hbase']['metrics']['prometheus']['port']}:#{node['hbase']['conf_dir']}/prometheus.yml"

    cookbook_file "#{node['hbase']['install_dir']}/lib/jmx_prometheus_javaagent.jar" do
      source 'jmx_prometheus_javaagent.jar'
      owner node['hbase']['user']
      group node['hbase']['group']
      mode '0644'
      action :create
    end

    template "#{node['hbase']['conf_dir']}/prometheus.yml" do
      source 'prometheus.yml.erb'
      owner node['hbase']['user']
      group node['hbase']['group']
      mode '0644'
      action :create
    end
  when 'graphite'
    env_vars['hbase_opts'] = "#{env_vars['hbase_opts']} -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
  end
end

hbase_config "#{node['hbase']['conf_dir']}/hbase-env.sh" do
  user node['hbase']['user']
  group node['hbase']['group']
  variables(env_vars)
  config_type 'env'
  action :create
end

# log4j2.properties - Logging configuration
hbase_config "#{node['hbase']['conf_dir']}/log4j2.properties" do
  user node['hbase']['user']
  group node['hbase']['group']
  variables(
    log_dir: node['hbase']['log_dir'],
    log_level: node['hbase']['log_level']
  )
  config_type 'properties'
  action :create
end

# regionservers - List of region servers
template "#{node['hbase']['conf_dir']}/regionservers" do
  source 'regionservers.erb'
  owner node['hbase']['user']
  group node['hbase']['group']
  mode '0644'
  variables(
    regionservers: node['hbase']['topology']['regionservers'].empty? ? ['localhost'] : node['hbase']['topology']['regionservers']
  )
  action :create
end

# backup-masters - List of backup masters (only in distributed mode)
if node['hbase']['config']['hbase.cluster.distributed']
  template "#{node['hbase']['conf_dir']}/backup-masters" do
    source 'backup-masters.erb'
    owner node['hbase']['user']
    group node['hbase']['group']
    mode '0644'
    variables(
      backup_masters: node['hbase']['topology']['backup_masters'] || []
    )
    action :create
    only_if { !node['hbase']['topology']['backup_masters'].nil? && !node['hbase']['topology']['backup_masters'].empty? }
  end
end

# Hadoop configuration files if using HDFS
if node['hbase']['config']['hbase.rootdir'].start_with?('hdfs://')
  # core-site.xml
  unless node['hbase']['hadoop']['core_site'].empty?
    hbase_config "#{node['hbase']['conf_dir']}/core-site.xml" do
      user node['hbase']['user']
      group node['hbase']['group']
      variables(node['hbase']['hadoop']['core_site'])
      config_type 'xml'
      use_helpers true
      action :create
    end
  end

  # hdfs-site.xml
  unless node['hbase']['hadoop']['hdfs_site'].empty?
    hbase_config "#{node['hbase']['conf_dir']}/hdfs-site.xml" do
      user node['hbase']['user']
      group node['hbase']['group']
      variables(node['hbase']['hadoop']['hdfs_site'])
      config_type 'xml'
      use_helpers true
      action :create
    end
  end
end
