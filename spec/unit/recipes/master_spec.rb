require 'spec_helper'

describe 'hbase::master' do
  context 'When all attributes are default, on Ubuntu 22.04' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates hbase master service' do
      expect(chef_run).to create_hbase_service('master').with(
        restart_on_config_change: true,
        service_config: {}
      )
    end

    it 'enables hbase master service' do
      expect(chef_run).to enable_hbase_service('master')
    end

    it 'starts hbase master service' do
      expect(chef_run).to start_hbase_service('master')
    end
  end

  context 'With custom service configuration' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.override['hbase']['service_mapping']['master']['config'] = {
        'hbase.master.port' => 16001,
        'hbase.master.info.port' => 16011,
      }
      runner.converge(described_recipe)
    end

    it 'creates hbase master service with custom config' do
      expect(chef_run).to create_hbase_service('master').with(
        service_config: {
          'hbase.master.port' => 16001,
          'hbase.master.info.port' => 16011,
        }
      )
    end
  end
end
