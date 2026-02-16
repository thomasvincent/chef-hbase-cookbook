require 'spec_helper'

describe 'hbase::install' do
  context 'When all attributes are default, on Ubuntu 22.04' do
    let(:chef_run) do
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

    it 'does not create hbase install directory for binary install' do
      expect(chef_run).not_to create_directory('/opt/hbase')
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

    # ark :install action manages the symlink at home_dir automatically
  end

  context 'When using package installation method' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.override['hbase']['install']['method'] = 'package'
      runner.node.override['hbase']['install']['packages'] = ['hbase']
      runner.converge(described_recipe)
    end

    it 'installs hbase package' do
      expect(chef_run).to install_package('hbase')
    end
  end
end
