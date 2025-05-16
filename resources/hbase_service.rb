provides :hbase_service
unified_mode true

resource_name :hbase_service
introduced '18.0'  # Indicate this resource is designed for Chef 18+

# Properties with descriptions for better documentation
property :service_name, String,
         name_property: true,
         description: 'Name of the HBase service (master, regionserver, etc.)'

property :user, String,
         default: lazy { node['hbase']['user'] },
         description: 'User to run the HBase service as'

property :group, String,
         default: lazy { node['hbase']['group'] },
         description: 'Group to run the HBase service as'

property :install_dir, String,
         default: lazy { node['hbase']['install_dir'] },
         description: 'Directory where HBase is installed'

property :log_dir, String,
         default: lazy { node['hbase']['log_dir'] },
         description: 'Directory where HBase logs are stored'

property :conf_dir, String,
         default: lazy { node['hbase']['conf_dir'] },
         description: 'Directory containing HBase configuration files'

property :java_home, String,
         default: lazy { node['hbase']['java_home'] },
         description: 'Path to the Java installation'

property :java_opts, String,
         default: lazy { node['hbase']['java_opts'] },
         description: 'Java options for the HBase service'

property :restart_on_config_change, [true, false],
         default: true,
         description: 'Whether to restart the service when configuration changes'

property :service_config, Hash,
         default: {},
         description: 'Service-specific configuration options'

# Helper methods at the resource level (Chef 18 style)
def service_unit_name
  "hbase-#{new_resource.service_name}.service"
end

def service_config_path
  "#{new_resource.conf_dir}/#{new_resource.service_name}-site.xml"
end

# Chef 18 style validation helpers
def validate_service_name!(name)
  valid_services = %w(master regionserver thrift rest)
  
  unless name.is_a?(String) && !name.empty?
    raise Chef::Exceptions::ValidationFailed, "Service name must be a non-empty string: #{name.inspect}"
  end
  
  unless valid_services.include?(name)
    Chef::Log.warn("HBase service name '#{name}' is not one of the standard services: #{valid_services.join(', ')}")
  end
end

def validate_directory!(path)
  unless path.is_a?(String) && !path.empty?
    raise Chef::Exceptions::ValidationFailed, "Directory path must be a non-empty string: #{path.inspect}"
  end
  
  if path.include?('..') || path !~ /^\//
    raise Chef::Exceptions::ValidationFailed, "Directory path must be absolute without traversal: #{path.inspect}"
  end
end

def validate_service_config!(config)
  unless config.is_a?(Hash)
    raise Chef::Exceptions::ValidationFailed, "Service config must be a Hash, got: #{config.class}"
  end
end

# Better organized action_class with improved validation 
action_class do
  # Chef 18 style comprehensive validation method
  def validate_resource_attributes!
    validate_service_name!(new_resource.service_name)
    validate_directory!(new_resource.install_dir)
    validate_directory!(new_resource.conf_dir)
    validate_directory!(new_resource.log_dir)
    validate_service_config!(new_resource.service_config)
    
    # Validate Java home if provided
    if new_resource.java_home && new_resource.java_home.to_s.strip != ''
      validate_directory!(new_resource.java_home)
    end
  end

  # Helper method to create specific service configs with error handling
  def create_service_config
    # Only create service-specific config if provided
    return if new_resource.service_config.empty?

    template service_config_path do
      source 'service-site.xml.erb'
      cookbook 'hbase'
      owner new_resource.user
      group new_resource.group
      mode '0644'
      variables(
        config: new_resource.service_config
      )
      notifies :restart, "systemd_unit[#{service_unit_name}]" if new_resource.restart_on_config_change
      
      # Error handling (Chef 18 feature)
      error_message "Failed to create service configuration for #{new_resource.service_name}"
      
      # Verification block (Chef 18 feature)
      verify do |path|
        begin
          require 'rexml/document'
          REXML::Document.new(::File.read(path))
          true
        rescue => e
          Chef::Log.error("XML verification failed: #{e.message}")
          false
        end
      end
      
      action :create
    end
  end
end

description 'Create the HBase service'
action :create do
  # Run comprehensive validation using Chef 18 style validations
  validate_resource_attributes!
  
  # Service pid file
  pid_dir = '/var/run/hbase'
  
  # Ensure PID directory exists - now with verification
  directory pid_dir do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
    action :create
    
    # Error handling (Chef 18 feature)
    error_message "Failed to create PID directory at #{pid_dir}"
    
    # Verification block (Chef 18 feature)
    verify do |dir|
      ::File.directory?(dir) && 
      ::File.owned?(dir) && 
      (::File.stat(dir).mode & 0o777) == 0o755
    end
  end

  # Use systemd_unit resource with more Chef 18 features
  systemd_unit service_unit_name do
    content({
      Unit: {
        Description: "Apache HBase #{new_resource.service_name.capitalize} Service",
        After: 'network.target',
        Documentation: 'https://hbase.apache.org',
        Wants: 'network-online.target' # Better dependency specification
      },
      Service: {
        Type: 'forking',
        User: new_resource.user,
        Group: new_resource.group,
        Environment: [
          "JAVA_HOME=#{new_resource.java_home}",
          "HBASE_OPTS=#{new_resource.java_opts}",
          "HBASE_LOG_DIR=#{new_resource.log_dir}" # Additional environment setting
        ],
        EnvironmentFile: "#{new_resource.conf_dir}/hbase-env.sh",
        ExecStart: "#{new_resource.install_dir}/current/bin/hbase-daemon.sh start #{new_resource.service_name}",
        ExecStop: "#{new_resource.install_dir}/current/bin/hbase-daemon.sh stop #{new_resource.service_name}",
        Restart: 'on-failure',
        RestartSec: '10s',
        TimeoutStartSec: '180s', # More generous startup timeout for big clusters
        LimitNOFILE: node['hbase']['limits']['nofile'],
        LimitNPROC: node['hbase']['limits']['nproc'],
        PIDFile: "#{pid_dir}/hbase-#{new_resource.user}-#{new_resource.service_name}.pid",
      },
      Install: {
        WantedBy: 'multi-user.target',
      },
    })
    verify true # Addition of systemd verify step 
    action :create
  end

  # Create service-specific configs if needed
  create_service_config
  
  # Log the service creation
  log "Created HBase #{new_resource.service_name} service" do
    level :info
  end
end

# Simplified action methods with descriptions (Chef 18 style)
description 'Enable the HBase service'
action :enable do
  service service_unit_name do
    action :enable
  end
  
  log "Enabled HBase #{new_resource.service_name} service" do
    level :info
  end
end

description 'Start the HBase service'
action :start do
  # Verify configuration before starting
  ruby_block "Verify HBase #{new_resource.service_name} configuration" do
    block do
      unless ::File.exist?(service_config_path) || new_resource.service_config.empty?
        Chef::Log.warn("Configuration for #{new_resource.service_name} does not exist at #{service_config_path}")
      end
    end
    action :run
    only_if { new_resource.service_name != 'master' || ::File.exist?("#{new_resource.conf_dir}/hbase-site.xml") }
  end

  service service_unit_name do
    action :start
  end
end

description 'Restart the HBase service'
action :restart do
  # Simplified logging of the restart action
  log "Restarting HBase #{new_resource.service_name} service" do
    level :info
    notifies :restart, "service[#{service_unit_name}]", :immediately
  end
  
  service service_unit_name do
    action :nothing
  end
end

description 'Disable the HBase service'
action :disable do
  service service_unit_name do
    action :disable
  end
end

description 'Stop the HBase service'
action :stop do
  service service_unit_name do
    action :stop
  end
end

# Add new action for reload (Chef 18 style)
description 'Reload the HBase service configuration'
action :reload do
  execute "Reload #{new_resource.service_name} configuration" do
    command "systemctl reload #{service_unit_name}"
    action :run
    only_if "systemctl is-active #{service_unit_name}"
  end
end