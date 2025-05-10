unified_mode true

property :path, String, name_property: true
property :user, String, default: lazy { node['hbase']['user'] }
property :group, String, default: lazy { node['hbase']['group'] }
property :mode, String, default: '0644'
property :variables, Hash, default: {}
property :config_type, String, equal_to: ['xml', 'properties', 'env', 'script'], default: 'xml'
property :template_source, String
property :restart_services, Array, default: []
property :use_helpers, [true, false], default: false

action :create do
  # Determine template source based on config_type if not explicitly provided
  source = new_resource.template_source
  unless source
    case new_resource.config_type
    when 'xml'
      source = 'hbase-site.xml.erb'
    when 'properties'
      source = 'log4j2.properties.erb'
    when 'env'
      source = 'hbase-env.sh.erb'
    when 'script'
      source = 'generic-script.erb'
    end
  end

  # Process variables if use_helpers is true
  final_variables = if new_resource.use_helpers && new_resource.config_type == 'xml'
                      { config: validate_config(new_resource.variables) }
                    else
                      new_resource.variables
                    end

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
    source source
    cookbook 'hbase'
    owner new_resource.user
    group new_resource.group
    mode new_resource.mode
    variables final_variables
    action :create

    # Restart services if specified
    unless new_resource.restart_services.empty?
      new_resource.restart_services.each do |svc|
        notifies :restart, "service[hbase-#{svc}]", :delayed
      end
    end
  end
end