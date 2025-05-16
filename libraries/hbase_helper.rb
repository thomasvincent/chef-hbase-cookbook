module HBase
  # Chef 18 style module organization with better documentation
  module Helper
    # Transforms a hash into sorted XML properties for hbase-site.xml
    # @param config [Hash] Configuration hash to transform
    # @return [String] XML formatted properties for hbase-site.xml
    def config_to_xml_properties(config = {})
      # Using modern Ruby features and clearer formatting
      config.sort.map do |key, value|
        <<~XML
          <property>
            <name>#{key}</name>
            <value>#{value}</value>
          </property>
        XML
      end.join("\n")
    end

    # Validates configuration values and provides sensible defaults
    # @param config [Hash] User provided configuration
    # @return [Hash] Configuration with defaults applied
    def validate_config(config = {})
      # Using Ruby keyword arguments and fetch with defaults
      required_configs = {
        'hbase.rootdir' => node['hbase']['config'].fetch('hbase.rootdir', 'file:///tmp/hbase'),
        'hbase.zookeeper.quorum' => node['hbase']['config'].fetch('hbase.zookeeper.quorum', 'localhost'),
        'hbase.cluster.distributed' => node['hbase']['config'].fetch('hbase.cluster.distributed', false)
      }
      
      # Merge with user config, giving precedence to user values
      required_configs.merge(config)
    end

    # Returns the HBase principal if Kerberos authentication is enabled
    # @return [String, nil] Kerberos principal or nil if not using Kerberos
    def hbase_principal
      # Using Ruby conditional assignment for cleaner code
      return nil unless node['hbase']['security']['authentication'] == 'kerberos'
      
      principal = node['hbase']['security']['kerberos']['principal']
      realm = node['hbase']['security']['kerberos']['realm']
      "#{principal}@#{realm}"
    end

    # Returns the ZooKeeper connection string
    # @return [String] ZooKeeper connection string in host:port format
    def zk_connection_string
      quorum = Array(node['hbase']['config']['hbase.zookeeper.quorum']).join(',').split(',')
      port = node['hbase']['config'].fetch('hbase.zookeeper.property.clientPort', '2181')
      
      # Using Ruby's &: shorthand for method calls
      quorum.map { |host| "#{host}:#{port}" }.join(',')
    end

    # Role helper methods combined with cleaner implementation
    # @return [Boolean] Whether this node has the specified role
    [:master, :regionserver, :backup_master].each do |role|
      define_method("#{role}?") do
        node['hbase']['topology']['role'] == role.to_s
      end
    end

    # Returns a list of nodes in the cluster with a specific role
    # @param role [String] Role to search for
    # @param environment [String] Chef environment to search in
    # @return [Array] Sorted list of matching nodes
    def nodes_with_role(role, environment = node.chef_environment)
      # Using Ruby's safe navigation operator &. 
      search_query = "chef_environment:#{environment} AND hbase_topology_role:#{role}"
      
      begin
        results = search(:node, search_query) || []
      rescue => e
        Chef::Log.warn("Could not search for nodes with role #{role}: #{e.message}")
        results = []
      end
      
      # Sort nodes by name
      results.sort_by { |n| n['name'] }
    end

    # Creates a hash of proper Java options
    # @return [String] Formatted Java options string
    def java_options
      # Using Ruby's string interpolation and array join for cleaner code
      opts = [node['hbase']['java_opts'].to_s]
      
      # Add security settings if using Kerberos
      if node['hbase']['security']['authentication'] == 'kerberos'
        opts << "-Djava.security.auth.login.config=#{node['hbase']['conf_dir']}/jaas.conf"
      end
      
      # Add standard HBase options
      opts << "-Dhbase.log.dir=#{node['hbase']['log_dir']}"
      opts << "-Dhbase.security.logger=#{node['hbase']['log_level']},console"
      
      # Join all options with spaces
      opts.compact.join(' ')
    end
  end
end

# Chef 18 style DSL inclusion
Chef::DSL::Recipe.include(HBase::Helper)
Chef::DSL::Universal.include(HBase::Helper)
Chef::DSL::Resource.include(HBase::Helper)

# Add metadata about this library (Chef 18 feature)
if defined?(Chef::ResourceInspector)
  Chef::ResourceInspector.add_location('HBase::Helper', __FILE__, __LINE__)
end