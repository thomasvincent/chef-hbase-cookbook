require 'spec_helper'

describe 'hbase::default' do
  context 'When all attributes are default, on Ubuntu 22.04' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/chefspec/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.override['hbase']['checksum'] = 'e0b79b53928e6e2424e1b8c16e9aa9a0dcbe2c20e05439473f9a8e05983b527b'
      runner.converge(described_recipe)
    end

    before do
      stub_command('test -L /opt/hbase/current').and_return(false)
      stub_command('java -version').and_return(true)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'includes the hbase::java recipe' do
      expect(chef_run).to include_recipe('hbase::java')
    end

    it 'includes the hbase::user recipe' do
      expect(chef_run).to include_recipe('hbase::user')
    end

    it 'includes the hbase::install recipe' do
      expect(chef_run).to include_recipe('hbase::install')
    end

    it 'includes the hbase::config recipe' do
      expect(chef_run).to include_recipe('hbase::config')
    end

    it 'creates hbase-site.xml' do
      expect(chef_run).to create_hbase_config("#{chef_run.node['hbase']['conf_dir']}/hbase-site.xml")
    end

    it 'creates hbase-env.sh' do
      expect(chef_run).to create_hbase_config("#{chef_run.node['hbase']['conf_dir']}/hbase-env.sh")
    end

    it 'creates log4j2.properties' do
      expect(chef_run).to create_hbase_config("#{chef_run.node['hbase']['conf_dir']}/log4j2.properties")
    end

    it 'creates hbase-master service' do
      expect(chef_run).to create_hbase_service('master')
    end

    it 'enables hbase-master service' do
      expect(chef_run).to enable_hbase_service('master')
    end

    it 'starts hbase-master service' do
      expect(chef_run).to start_hbase_service('master')
    end
  end

  context 'When run as a region server' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.override['hbase']['checksum'] = 'e0b79b53928e6e2424e1b8c16e9aa9a0dcbe2c20e05439473f9a8e05983b527b'
      runner.node.override['hbase']['topology']['role'] = 'regionserver'
      runner.converge(described_recipe)
    end

    before do
      stub_command('test -L /opt/hbase/current').and_return(false)
      stub_command('java -version').and_return(true)
    end

    it 'includes the hbase::regionserver recipe' do
      expect(chef_run).to include_recipe('hbase::regionserver')
    end
  end

  context 'When thrift service is enabled' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.override['hbase']['checksum'] = 'e0b79b53928e6e2424e1b8c16e9aa9a0dcbe2c20e05439473f9a8e05983b527b'
      runner.node.override['hbase']['services']['thrift']['enabled'] = true
      runner.converge(described_recipe)
    end

    before do
      stub_command('test -L /opt/hbase/current').and_return(false)
      stub_command('java -version').and_return(true)
    end

    it 'includes the hbase::thrift recipe' do
      expect(chef_run).to include_recipe('hbase::thrift')
    end
  end

  context 'When REST service is enabled' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.override['hbase']['checksum'] = 'e0b79b53928e6e2424e1b8c16e9aa9a0dcbe2c20e05439473f9a8e05983b527b'
      runner.node.override['hbase']['services']['rest']['enabled'] = true
      runner.converge(described_recipe)
    end

    before do
      stub_command('test -L /opt/hbase/current').and_return(false)
      stub_command('java -version').and_return(true)
    end

    it 'includes the hbase::rest recipe' do
      expect(chef_run).to include_recipe('hbase::rest')
    end
  end
end
