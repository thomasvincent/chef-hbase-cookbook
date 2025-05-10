require 'spec_helper'

describe 'hbase_config' do
  step_into :hbase_config
  platform 'ubuntu'
  version '22.04'

  context 'create action for XML config' do
    recipe do
      hbase_config '/etc/hbase/conf/test-site.xml' do
        user 'hbase'
        group 'hbase'
        variables({
          'test.prop1' => 'value1',
          'test.prop2' => 'value2'
        })
        config_type 'xml'
        action :create
      end
    end

    it 'creates parent directory if needed' do
      is_expected.to create_directory('/etc/hbase/conf').with(
        owner: 'hbase',
        group: 'hbase',
        mode: '0755',
        recursive: true
      )
    end

    it 'creates the config file' do
      is_expected.to create_template('/etc/hbase/conf/test-site.xml').with(
        source: 'hbase-site.xml.erb',
        cookbook: 'hbase',
        owner: 'hbase',
        group: 'hbase',
        mode: '0644'
      )
    end
  end

  context 'create action for env file' do
    recipe do
      hbase_config '/etc/hbase/conf/test-env.sh' do
        user 'hbase'
        group 'hbase'
        variables({
          'java_home' => '/usr/lib/jvm/java-11',
          'hbase_opts' => '-Xmx2048m'
        })
        config_type 'env'
        action :create
      end
    end

    it 'creates the env file with correct template' do
      is_expected.to create_template('/etc/hbase/conf/test-env.sh').with(
        source: 'hbase-env.sh.erb',
        cookbook: 'hbase',
        owner: 'hbase',
        group: 'hbase',
        mode: '0644'
      )
    end
  end

  context 'create action for properties file' do
    recipe do
      hbase_config '/etc/hbase/conf/test.properties' do
        user 'hbase'
        group 'hbase'
        variables({
          'log_dir' => '/var/log/hbase',
          'log_level' => 'DEBUG'
        })
        config_type 'properties'
        action :create
      end
    end

    it 'creates the properties file with correct template' do
      is_expected.to create_template('/etc/hbase/conf/test.properties').with(
        source: 'log4j2.properties.erb',
        cookbook: 'hbase',
        owner: 'hbase',
        group: 'hbase',
        mode: '0644'
      )
    end
  end

  context 'create action for script file' do
    recipe do
      hbase_config '/etc/hbase/conf/test-script.sh' do
        user 'hbase'
        group 'hbase'
        variables({
          'content' => '#!/bin/bash\necho "Hello"'
        })
        config_type 'script'
        mode '0755'
        action :create
      end
    end

    it 'creates the script file with correct template' do
      is_expected.to create_template('/etc/hbase/conf/test-script.sh').with(
        source: 'generic-script.erb',
        cookbook: 'hbase',
        owner: 'hbase',
        group: 'hbase',
        mode: '0755'
      )
    end
  end

  context 'with custom template source' do
    recipe do
      hbase_config '/etc/hbase/conf/custom.xml' do
        user 'hbase'
        group 'hbase'
        template_source 'custom-template.erb'
        variables({
          'test.prop1' => 'value1',
          'test.prop2' => 'value2'
        })
        config_type 'xml'
        action :create
      end
    end

    it 'creates the config file with custom template' do
      is_expected.to create_template('/etc/hbase/conf/custom.xml').with(
        source: 'custom-template.erb',
        cookbook: 'hbase',
        owner: 'hbase',
        group: 'hbase',
        mode: '0644'
      )
    end
  end

  context 'with restart_services' do
    recipe do
      hbase_config '/etc/hbase/conf/restart-test.xml' do
        user 'hbase'
        group 'hbase'
        variables({
          'test.prop1' => 'value1'
        })
        config_type 'xml'
        restart_services ['master', 'regionserver']
        action :create
      end
    end

    it 'creates the config file with restart notifications' do
      is_expected.to create_template('/etc/hbase/conf/restart-test.xml').with(
        notifies: [:restart, 'service[hbase-master]', :delayed],
        notifies: [:restart, 'service[hbase-regionserver]', :delayed]
      )
    end
  end

  context 'with helper usage' do
    recipe do
      hbase_config '/etc/hbase/conf/helper-test.xml' do
        user 'hbase'
        group 'hbase'
        variables({
          'test.prop1' => 'value1',
          'test.prop2' => 'value2'
        })
        config_type 'xml'
        use_helpers true
        action :create
      end
    end

    it 'creates the config file using helpers' do
      is_expected.to create_template('/etc/hbase/conf/helper-test.xml').with(
        source: 'hbase-site.xml.erb',
        cookbook: 'hbase',
        owner: 'hbase',
        group: 'hbase',
        mode: '0644'
      )
    end
  end
end