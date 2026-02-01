require 'spec_helper'

describe 'hbase::regionserver' do
  context 'When all attributes are default, on Ubuntu 22.04' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates hbase regionserver service' do
      expect(chef_run).to create_hbase_service('regionserver').with(
        restart_on_config_change: true,
        service_config: {}
      )
    end

    it 'enables hbase regionserver service' do
      expect(chef_run).to enable_hbase_service('regionserver')
    end

    it 'starts hbase regionserver service' do
      expect(chef_run).to start_hbase_service('regionserver')
    end
  end

  context 'With custom service configuration' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04')
      runner.node.override['hbase']['service_mapping']['regionserver']['config'] = {
        'hbase.regionserver.port' => 16021,
        'hbase.regionserver.info.port' => 16031,
      }
      runner.converge(described_recipe)
    end

    it 'creates hbase regionserver service with custom config' do
      expect(chef_run).to create_hbase_service('regionserver').with(
        service_config: {
          'hbase.regionserver.port' => 16021,
          'hbase.regionserver.info.port' => 16031,
        }
      )
    end
  end
end
