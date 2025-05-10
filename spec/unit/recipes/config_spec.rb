require 'spec_helper'

describe 'hbase::config' do
  context 'When all attributes are default, on Ubuntu 22.04' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '22.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates hbase-site.xml' do
      expect(chef_run).to create_hbase_config("#{chef_run.node['hbase']['conf_dir']}/hbase-site.xml").with(
        user: 'hbase',
        group: 'hbase',
        config_type: 'xml',
        use_helpers: true
      )
    end

    it 'creates hbase-env.sh' do
      expect(chef_run).to create_hbase_config("#{chef_run.node['hbase']['conf_dir']}/hbase-env.sh").with(
        user: 'hbase',
        group: 'hbase',
        config_type: 'env'
      )
    end

    it 'creates log4j2.properties' do
      expect(chef_run).to create_hbase_config("#{chef_run.node['hbase']['conf_dir']}/log4j2.properties").with(
        user: 'hbase',
        group: 'hbase',
        config_type: 'properties'
      )
    end

    it 'creates regionservers file' do
      expect(chef_run).to create_template("#{chef_run.node['hbase']['conf_dir']}/regionservers").with(
        owner: 'hbase',
        group: 'hbase',
        mode: '0644'
      )
    end
  end

  context 'When using Kerberos authentication' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.normal['hbase']['security']['authentication'] = 'kerberos'
      runner.node.normal['hbase']['security']['kerberos']['principal'] = 'hbase/_HOST'
      runner.node.normal['hbase']['security']['kerberos']['keytab'] = '/etc/hbase/conf/hbase.keytab'
      runner.node.normal['hbase']['security']['kerberos']['realm'] = 'EXAMPLE.COM'
      runner.converge(described_recipe)
    end

    it 'creates jaas.conf' do
      expect(chef_run).to create_template("#{chef_run.node['hbase']['conf_dir']}/jaas.conf").with(
        owner: 'hbase',
        group: 'hbase',
        mode: '0600'
      )
    end
  end

  context 'When using HDFS for rootdir' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.normal['hbase']['config']['hbase.rootdir'] = 'hdfs://namenode:8020/hbase'
      runner.node.normal['hbase']['hadoop']['core_site'] = { 'fs.defaultFS' => 'hdfs://namenode:8020' }
      runner.node.normal['hbase']['hadoop']['hdfs_site'] = { 'dfs.replication' => 3 }
      runner.converge(described_recipe)
    end

    it 'creates core-site.xml' do
      expect(chef_run).to create_hbase_config("#{chef_run.node['hbase']['conf_dir']}/core-site.xml").with(
        user: 'hbase',
        group: 'hbase',
        config_type: 'xml',
        use_helpers: true
      )
    end

    it 'creates hdfs-site.xml' do
      expect(chef_run).to create_hbase_config("#{chef_run.node['hbase']['conf_dir']}/hdfs-site.xml").with(
        user: 'hbase',
        group: 'hbase',
        config_type: 'xml',
        use_helpers: true
      )
    end
  end

  context 'When running in distributed mode with backup masters' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.normal['hbase']['config']['hbase.cluster.distributed'] = true
      runner.node.normal['hbase']['topology']['backup_masters'] = ['backup1.example.com', 'backup2.example.com']
      runner.converge(described_recipe)
    end

    it 'creates backup-masters file' do
      expect(chef_run).to create_template("#{chef_run.node['hbase']['conf_dir']}/backup-masters").with(
        owner: 'hbase',
        group: 'hbase',
        mode: '0644'
      )
    end
  end
end