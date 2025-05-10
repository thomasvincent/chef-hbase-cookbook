require 'spec_helper'

describe 'hbase::install' do
  context 'When all attributes are default, on Ubuntu 22.04' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '22.04')
      runner.converge(described_recipe)
    end

    before do
      stub_command('test -L /opt/hbase/current').and_return(false)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates hbase install directory' do
      expect(chef_run).to create_directory('/opt/hbase').with(
        owner: 'hbase',
        group: 'hbase',
        mode: '0755'
      )
    end

    it 'creates hbase conf directory' do
      expect(chef_run).to create_directory('/etc/hbase/conf').with(
        owner: 'hbase',
        group: 'hbase',
        mode: '0755'
      )
    end

    it 'creates hbase log directory' do
      expect(chef_run).to create_directory('/var/log/hbase').with(
        owner: 'hbase',
        group: 'hbase',
        mode: '0755'
      )
    end

    it 'creates hbase pid directory' do
      expect(chef_run).to create_directory('/var/run/hbase').with(
        owner: 'hbase',
        group: 'hbase',
        mode: '0755'
      )
    end

    it 'installs hbase using ark' do
      expect(chef_run).to install_ark('hbase')
    end

    it 'creates a symlink to the current version' do
      expect(chef_run).to create_link('/opt/hbase/current')
    end
  end

  context 'When using package installation method' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.normal['hbase']['install']['method'] = 'package'
      runner.node.normal['hbase']['install']['packages'] = ['hbase']
      runner.converge(described_recipe)
    end

    it 'installs hbase package' do
      expect(chef_run).to install_package('hbase')
    end
  end
end