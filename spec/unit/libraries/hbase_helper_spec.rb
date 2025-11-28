require 'spec_helper'
require_relative '../../../libraries/hbase_helper'

describe HBase::Helper do
  let(:dummy_class) do
    Class.new do
      include HBase::Helper
      attr_accessor :node

      def initialize
        @node = {
          'hbase' => {
            'config' => {
              'hbase.rootdir' => 'file:///var/hbase',
              'hbase.zookeeper.quorum' => 'localhost',
              'hbase.zookeeper.property.clientPort' => '2181',
              'hbase.cluster.distributed' => false,
            },
            'security' => {
              'authentication' => 'simple',
              'kerberos' => {
                'principal' => 'hbase/_HOST',
                'realm' => 'EXAMPLE.COM',
              },
            },
            'java_opts' => '-Xmx1024m',
            'log_dir' => '/var/log/hbase',
            'log_level' => 'INFO',
            'conf_dir' => '/etc/hbase/conf',
            'topology' => {
              'role' => 'master',
            },
          },
        }
      end

      def [](key)
        @node[key]
      end
    end
  end

  let(:helper) { dummy_class.new }

  describe '#config_to_xml_properties' do
    it 'transforms a hash into sorted XML properties' do
      config = {
        'property.two' => 'value2',
        'property.one' => 'value1',
      }

      result = helper.config_to_xml_properties(config)
      expect(result).to include('<property>')
      expect(result).to include('<name>property.one</name>')
      expect(result).to include('<value>value1</value>')
      expect(result).to include('<name>property.two</name>')
      expect(result).to include('<value>value2</value>')
      # Should be sorted
      expect(result.index('property.one')).to be < result.index('property.two')
    end
  end

  describe '#validate_config' do
    it 'fills in required configurations with defaults if not provided' do
      custom_config = { 'custom.property' => 'custom_value' }
      result = helper.validate_config(custom_config)

      # Should have all default values
      expect(result['hbase.rootdir']).to eq('file:///var/hbase')
      expect(result['hbase.zookeeper.quorum']).to eq('localhost')
      expect(result['hbase.cluster.distributed']).to eq(false)

      # Should preserve custom values
      expect(result['custom.property']).to eq('custom_value')
    end

    it 'preserves provided values over defaults' do
      custom_config = {
        'custom.property' => 'custom_value',
        'hbase.rootdir' => 'hdfs://example:8020/hbase',
      }
      result = helper.validate_config(custom_config)

      # Custom value should override default
      expect(result['hbase.rootdir']).to eq('hdfs://example:8020/hbase')

      # Other defaults should be preserved
      expect(result['hbase.zookeeper.quorum']).to eq('localhost')
      expect(result['hbase.cluster.distributed']).to eq(false)
    end
  end

  describe '#hbase_principal' do
    it 'returns nil when authentication is not kerberos' do
      expect(helper.hbase_principal).to be_nil
    end

    it 'returns the principal with realm when kerberos is enabled' do
      helper.node['hbase']['security']['authentication'] = 'kerberos'
      expect(helper.hbase_principal).to eq('hbase/_HOST@EXAMPLE.COM')
    end
  end

  describe '#zk_connection_string' do
    it 'returns the zookeeper connection string with port' do
      expect(helper.zk_connection_string).to eq('localhost:2181')
    end

    it 'handles multiple quorum members' do
      helper.node['hbase']['config']['hbase.zookeeper.quorum'] = 'zk1,zk2,zk3'
      expect(helper.zk_connection_string).to eq('zk1:2181,zk2:2181,zk3:2181')
    end
  end

  describe '#master?' do
    it 'returns true when node role is master' do
      helper.node['hbase']['topology']['role'] = 'master'
      expect(helper.master?).to be true
    end

    it 'returns false when node role is not master' do
      helper.node['hbase']['topology']['role'] = 'regionserver'
      expect(helper.master?).to be false
    end
  end

  describe '#regionserver?' do
    it 'returns true when node role is regionserver' do
      helper.node['hbase']['topology']['role'] = 'regionserver'
      expect(helper.regionserver?).to be true
    end

    it 'returns false when node role is not regionserver' do
      helper.node['hbase']['topology']['role'] = 'master'
      expect(helper.regionserver?).to be false
    end
  end

  describe '#backup_master?' do
    it 'returns true when node role is backup_master' do
      helper.node['hbase']['topology']['role'] = 'backup_master'
      expect(helper.backup_master?).to be true
    end

    it 'returns false when node role is not backup_master' do
      helper.node['hbase']['topology']['role'] = 'master'
      expect(helper.backup_master?).to be false
    end
  end

  describe '#java_options' do
    it 'returns the base java options' do
      expect(helper.java_options).to include('-Xmx1024m')
      expect(helper.java_options).to include('-Dhbase.log.dir=/var/log/hbase')
      expect(helper.java_options).to include('-Dhbase.security.logger=INFO,console')
    end

    it 'adds kerberos options when kerberos is enabled' do
      helper.node['hbase']['security']['authentication'] = 'kerberos'
      expect(helper.java_options).to include('-Djava.security.auth.login.config=/etc/hbase/conf/jaas.conf')
    end
  end
end
