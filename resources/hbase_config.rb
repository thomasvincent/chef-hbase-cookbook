unified_mode true

provides :hbase_config

property :path, String, name_property: true
property :user, String, default: lazy { node['hbase']['user'] }
property :group, String, default: lazy { node['hbase']['group'] }
property :mode, String, default: '0644'
property :variables, Hash, default: {}
property :config_type, String, equal_to: ['xml', 'properties', 'env', 'script'], default: 'xml'
property :template_source, String
property :restart_services, Array, default: []
property :use_helpers, [true, false], default: false

action_class do
  # Select appropriate template based on config_type
  def determine_template_source
    new_resource.template_source || case new_resource.config_type
                                    when 'xml'
                                      'hbase-site.xml.erb'
                                    when 'properties'
                                      'log4j2.properties.erb'
                                    when 'env'
                                      'hbase-env.sh.erb'
                                    when 'script'
                                      'generic-script.erb'
                                    end
  end

  # Process variables applying helpers if needed
  def process_variables
    if new_resource.use_helpers && new_resource.config_type == 'xml'
      { config: validate_config(new_resource.variables) }
    else
      new_resource.variables
    end
  end
end

action :create do
  # Create parent directory if needed
  directory ::File.dirname(new_resource.path) do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
    action :create
    not_if { ::File.directory?(::File.dirname(new_resource.path)) }
  end

  # Create/update configuration file
  template new_resource.path do
    source determine_template_source
    cookbook 'hbase'
    owner new_resource.user
    group new_resource.group
    mode new_resource.mode
    variables process_variables
    action :create

    # Restart services if specified
    unless new_resource.restart_services.empty?
      new_resource.restart_services.each do |svc|
        notifies :restart, "service[hbase-#{svc}]", :delayed
      end
    end
  end
end