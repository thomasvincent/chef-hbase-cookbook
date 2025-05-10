require 'spec_helper'

describe 'hbase::user' do
  context 'When all attributes are default, on Ubuntu 22.04' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '22.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates hbase group' do
      expect(chef_run).to create_group('hbase').with(
        gid: 2313,
        system: true
      )
    end

    it 'creates hbase user' do
      expect(chef_run).to create_user('hbase').with(
        uid: 2313,
        gid: 2313,
        system: true,
        home: '/opt/hbase',
        shell: '/bin/bash'
      )
    end

    it 'creates limits configuration' do
      expect(chef_run).to create_template('/etc/security/limits.d/hbase.conf').with(
        mode: '0644'
      )
    end
  end

  context 'When user attributes are customized' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.normal['hbase']['user'] = 'custom_hbase'
      runner.node.normal['hbase']['group'] = 'custom_hbase'
      runner.node.normal['hbase']['uid'] = 1234
      runner.node.normal['hbase']['gid'] = 1234
      runner.converge(described_recipe)
    end

    it 'creates custom hbase group' do
      expect(chef_run).to create_group('custom_hbase').with(
        gid: 1234,
        system: true
      )
    end

    it 'creates custom hbase user' do
      expect(chef_run).to create_user('custom_hbase').with(
        uid: 1234,
        gid: 1234,
        system: true
      )
    end
  end
end