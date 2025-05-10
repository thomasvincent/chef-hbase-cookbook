module HBase
  module Helper
    # Transforms a hash into sorted XML properties for hbase-site.xml
    def config_to_xml_properties(config = {})
      config.sort.map do |key, value|
        property = '<property>'
        property += "\n  <name>#{key}</name>"
        property += "\n  <value>#{value}</value>"
        property += "\n</property>"
        property
      end.join("\n")
    end

    # Validates configuration values and provides sensible defaults
    def validate_config(config = {})
      # Required configurations with defaults if not explicitly set
      {
        'hbase.rootdir' => node['hbase']['config']['hbase.rootdir'],
        'hbase.zookeeper.quorum' => node['hbase']['config']['hbase.zookeeper.quorum'],
        'hbase.cluster.distributed' => node['hbase']['config']['hbase.cluster.distributed']
      }.merge(config)
    end

    # Returns the HBase principal if Kerberos authentication is enabled
    def hbase_principal
      if node['hbase']['security']['authentication'] == 'kerberos'
        principal = node['hbase']['security']['kerberos']['principal']
        "#{principal}@#{node['hbase']['security']['kerberos']['realm']}"
      else
        nil
      end
    end

    # Returns the ZooKeeper connection string
    def zk_connection_string
      quorum = node['hbase']['config']['hbase.zookeeper.quorum'].split(',')
      port = node['hbase']['config']['hbase.zookeeper.property.clientPort'] || '2181'
      quorum.map { |host| "#{host}:#{port}" }.join(',')
    end

    # Determines if the node is an HBase master
    def master?
      node['hbase']['topology']['role'] == 'master'
    end

    # Determines if the node is an HBase region server
    def regionserver?
      node['hbase']['topology']['role'] == 'regionserver'
    end

    # Determines if the node is an HBase backup master
    def backup_master?
      node['hbase']['topology']['role'] == 'backup_master'
    end

    # Returns a list of nodes in the cluster with a specific role
    def nodes_with_role(role, environment = node.chef_environment)
      results = search(:node, "chef_environment:#{environment} AND hbase_topology_role:#{role}")
      results.sort_by { |n| n['name'] }
    end

    # Creates a hash of proper Java options
    def java_options
      opts = node['hbase']['java_opts'].to_s
      opts += " -Djava.security.auth.login.config=#{node['hbase']['conf_dir']}/jaas.conf" if node['hbase']['security']['authentication'] == 'kerberos'
      opts += " -Dhbase.log.dir=#{node['hbase']['log_dir']}"
      opts += " -Dhbase.security.logger=#{node['hbase']['log_level']},console"
      opts
    end
  end
end

Chef::Recipe.include(HBase::Helper)
Chef::Resource.include(HBase::Helper)