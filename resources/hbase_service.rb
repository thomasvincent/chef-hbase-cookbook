unified_mode true

property :service_name, String, name_property: true
property :user, String, default: lazy { node['hbase']['user'] }
property :group, String, default: lazy { node['hbase']['group'] }
property :install_dir, String, default: lazy { node['hbase']['install_dir'] }
property :log_dir, String, default: lazy { node['hbase']['log_dir'] }
property :conf_dir, String, default: lazy { node['hbase']['conf_dir'] }
property :java_home, String, default: lazy { node['hbase']['java_home'] }
property :java_opts, String, default: lazy { node['hbase']['java_opts'] }
property :restart_on_config_change, [true, false], default: true
property :service_config, Hash, default: {}

action :create do
  systemd_unit "hbase-#{new_resource.service_name}.service" do
    content({
      Unit: {
        Description: "Apache HBase #{new_resource.service_name.capitalize} Service",
        After: 'network.target',
        Documentation: 'https://hbase.apache.org',
      },
      Service: {
        Type: 'forking',
        User: new_resource.user,
        Group: new_resource.group,
        Environment: "JAVA_HOME=#{new_resource.java_home}",
        Environment: "HBASE_OPTS=#{new_resource.java_opts}",
        EnvironmentFile: "#{new_resource.conf_dir}/hbase-env.sh",
        ExecStart: "#{new_resource.install_dir}/current/bin/hbase-daemon.sh start #{new_resource.service_name}",
        ExecStop: "#{new_resource.install_dir}/current/bin/hbase-daemon.sh stop #{new_resource.service_name}",
        Restart: 'on-failure',
        RestartSec: '10s',
        LimitNOFILE: node['hbase']['limits']['nofile'],
        LimitNPROC: node['hbase']['limits']['nproc'],
        PIDFile: "/var/run/hbase/hbase-#{new_resource.user}-#{new_resource.service_name}.pid",
      },
      Install: {
        WantedBy: 'multi-user.target',
      },
    })
    action :create
  end

  # Create service-specific configs if needed
  unless new_resource.service_config.empty?
    template "#{new_resource.conf_dir}/#{new_resource.service_name}-site.xml" do
      source 'service-site.xml.erb'
      cookbook 'hbase'
      owner new_resource.user
      group new_resource.group
      mode '0644'
      variables(
        config: new_resource.service_config
      )
      action :create
      notifies :restart, "systemd_unit[hbase-#{new_resource.service_name}.service]" if new_resource.restart_on_config_change
    end
  end
end

action :enable do
  service "hbase-#{new_resource.service_name}" do
    action :enable
  end
end

action :start do
  service "hbase-#{new_resource.service_name}" do
    action :start
  end
end

action :restart do
  service "hbase-#{new_resource.service_name}" do
    action :restart
  end
end

action :disable do
  service "hbase-#{new_resource.service_name}" do
    action :disable
  end
end

action :stop do
  service "hbase-#{new_resource.service_name}" do
    action :stop
  end
end