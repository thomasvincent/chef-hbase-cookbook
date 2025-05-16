provides :hbase_config
resource_name :hbase_config
unified_mode true
introduced '18.0'  # Indicate this resource is designed for Chef 18+

# Using Chef 18's simplified property declaration with lazy loading
property :path, String, 
         name_property: true, 
         description: 'The path to the configuration file',
         desired_state: true

# User/Group properties with improved lazy loading for Chef 18
property :user, String, 
         default: lazy { node['hbase']['user'] }, 
         description: 'User owner of the configuration file',
         identity: true  # Mark as identity property

property :group, String, 
         default: lazy { node['hbase']['group'] }, 
         description: 'Group owner of the configuration file',
         identity: true  # Mark as identity property

property :mode, String, 
         default: '0644', 
         description: 'File permissions for the configuration file',
         identity: true  # Mark as identity property

# Complex property with validation
property :variables, Hash, 
         default: {},
         coerce: proc { |v| v.is_a?(Hash) ? v : {} },
         description: 'Configuration variables to use in the template'

# Enum property with improved validation and documentation
property :config_type, String, 
         equal_to: ['xml', 'properties', 'env', 'script'], 
         default: 'xml',
         description: 'Type of configuration file to create',
         callbacks: {
           "must be one of: 'xml', 'properties', 'env', or 'script'" => lambda { |t|
             ['xml', 'properties', 'env', 'script'].include?(t)
           }
         }

property :template_source, String, 
         description: 'Custom template source to use instead of the default'

property :restart_services, Array, 
         default: [], 
         description: 'Services to restart when configuration changes'

property :use_helpers, [true, false], 
         default: false, 
         description: 'Whether to apply helper methods to process variables'

# Chef 18 style helper method - define outside of action_class for better organization
def template_map
  {
    'xml' => 'hbase-site.xml.erb',
    'properties' => 'log4j2.properties.erb',
    'env' => 'hbase-env.sh.erb',
    'script' => 'generic-script.erb'
  }
end

# Chef 18 style validation helpers
def validate_path!(path)
  unless path.is_a?(String) && !path.empty?
    raise Chef::Exceptions::ValidationFailed, "Path must be a non-empty string: #{path.inspect}"
  end
  
  if path.include?('..') || path !~ /^\//
    raise Chef::Exceptions::ValidationFailed, "Path must be an absolute path without directory traversal: #{path.inspect}"
  end
end

def validate_variables!(vars)
  return if vars.is_a?(Hash)
  
  raise Chef::Exceptions::ValidationFailed, "Variables must be a Hash, got: #{vars.class}"
end

def validate_config_type!(type)
  valid_types = ['xml', 'properties', 'env', 'script']
  return if valid_types.include?(type)
  
  raise Chef::Exceptions::ValidationFailed, 
        "Config type must be one of: #{valid_types.join(', ')}, got: #{type.inspect}"
end

# Using action_class for action-specific methods with validation
action_class do
  # Chef 18 style validation in action_class
  def validate_resource_attributes!
    validate_path!(new_resource.path)
    validate_variables!(new_resource.variables)
    validate_config_type!(new_resource.config_type)
  end

  # Select appropriate template based on config_type
  def determine_template_source
    new_resource.template_source || template_map[new_resource.config_type]
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

# Description block for the action (Chef 18 feature)
description 'Create an HBase configuration file'
action :create do
  # Run validations using new Chef 18 validator methods
  validate_resource_attributes!
  
  # Create parent directory if needed - using conditional guard with Chef 18 style
  config_parent_dir = ::File.dirname(new_resource.path)
  
  directory config_parent_dir do
    owner new_resource.user
    group new_resource.group
    mode '0755'
    recursive true
    # Use the guard property instead of not_if for Chef 18 style
    only_if { !::File.directory?(config_parent_dir) }
  end

  # Create/update configuration file with additional validation and error handling
  template new_resource.path do
    source determine_template_source
    cookbook 'hbase'
    owner new_resource.user
    group new_resource.group
    mode new_resource.mode
    variables process_variables
    
    # Chef 18 style notifications - more concise with collections
    new_resource.restart_services.each do |svc|
      notifies :restart, "service[hbase-#{svc}]", :delayed
    end
    
    # Error handling (Chef 18 feature)
    error_message "Failed to create configuration file at #{new_resource.path}"
    
    # Verification block (Chef 18 feature)
    verify do |path|
      begin
        if new_resource.config_type == 'xml'
          require 'rexml/document'
          REXML::Document.new(::File.read(path))
          true
        else
          ::File.exist?(path)
        end
      rescue => e
        Chef::Log.error("Config verification failed: #{e.message}")
        false
      end
    end
  end
  
  # Use log resource with Chef 18 properties
  log "Created HBase config at #{new_resource.path}" do
    level :info
    sensitive false
  end
  
  # Return a proper convergence report (Chef 18 feature)
  updated_by_last_action(true) if template(new_resource.path).updated_by_last_action?
end