require 'spec_helper'

describe 'hbase_service' do
  step_into :hbase_service
  platform 'ubuntu'
  version '22.04'

  context 'create action' do
    recipe do
      hbase_service 'master' do
        user 'hbase'
        group 'hbase'
        install_dir '/opt/hbase'
        conf_dir '/etc/hbase/conf'
        java_home '/usr/lib/jvm/java-11-openjdk'
        java_opts '-Xmx1024m'
        action :create
      end
    end

    it 'creates systemd service unit' do
      is_expected.to create_systemd_unit('hbase-master.service').with(
        content: {
          Unit: {
            Description: 'Apache HBase Master Service',
            After: 'network.target',
            Documentation: 'https://hbase.apache.org'
          },
          Service: {
            Type: 'forking',
            User: 'hbase',
            Group: 'hbase',
            Environment: [
              'JAVA_HOME=/usr/lib/jvm/java-11-openjdk',
              'HBASE_OPTS=-Xmx1024m'
            ],
            ExecStart: '/opt/hbase/current/bin/hbase-daemon.sh start master',
            ExecStop: '/opt/hbase/current/bin/hbase-daemon.sh stop master',
            Restart: 'on-failure',
          },
          Install: {
            WantedBy: 'multi-user.target'
          }
        }
      )
    end
  end

  context 'with service_config' do
    recipe do
      hbase_service 'master' do
        service_config({
          'hbase.master.port' => 16001,
          'hbase.master.info.port' => 16011
        })
        action :create
      end
    end

    it 'creates service-specific config file' do
      is_expected.to create_template('/etc/hbase/conf/master-site.xml').with(
        owner: 'hbase',
        group: 'hbase',
        mode: '0644'
      )
    end
  end

  context 'action start' do
    recipe do
      hbase_service 'master' do
        action [:create, :start]
      end
    end

    it 'starts the service' do
      is_expected.to start_service('hbase-master')
    end
  end

  context 'action enable' do
    recipe do
      hbase_service 'master' do
        action [:create, :enable]
      end
    end

    it 'enables the service' do
      is_expected.to enable_service('hbase-master')
    end
  end

  context 'action restart' do
    recipe do
      hbase_service 'master' do
        action [:create, :restart]
      end
    end

    it 'restarts the service' do
      is_expected.to restart_service('hbase-master')
    end
  end

  context 'action stop' do
    recipe do
      hbase_service 'master' do
        action [:create, :stop]
      end
    end

    it 'stops the service' do
      is_expected.to stop_service('hbase-master')
    end
  end

  context 'action disable' do
    recipe do
      hbase_service 'master' do
        action [:create, :disable]
      end
    end

    it 'disables the service' do
      is_expected.to disable_service('hbase-master')
    end
  end
end