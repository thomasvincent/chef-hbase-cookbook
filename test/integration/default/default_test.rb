# InSpec test for HBase cookbook

title 'HBase Cookbook Integration Tests'

# Basic System Configuration
control 'hbase-1.0' do
  impact 1.0
  title 'Basic system configuration'
  desc 'Validates the system user, groups and directories are properly configured'
  
  # Check for user/group
  describe user('hbase') do
    it { should exist }
    its('uid') { should eq 2313 }
    its('group') { should eq 'hbase' }
  end

  describe group('hbase') do
    it { should exist }
    its('gid') { should eq 2313 }
  end

  # Check for directories
  describe directory('/opt/hbase') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0755' }
  end

  describe directory('/etc/hbase/conf') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0755' }
  end

  describe directory('/var/log/hbase') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0755' }
  end

  describe directory('/var/run/hbase') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0755' }
  end
end

# Configuration Files
control 'hbase-2.0' do
  impact 1.0
  title 'Configuration files'
  desc 'Validates that all required configuration files exist and have correct ownership'

  # Check for configuration files
  describe file('/etc/hbase/conf/hbase-site.xml') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0644' }
    its('content') { should match /<name>hbase.rootdir<\/name>/ }
  end

  describe file('/etc/hbase/conf/hbase-env.sh') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'JAVA_HOME=' }
    its('content') { should include 'HBASE_LOG_DIR=' }
  end

  describe file('/etc/hbase/conf/log4j2.properties') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0644' }
  end

  describe file('/etc/hbase/conf/regionservers') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'localhost' }
  end

  describe file('/etc/security/limits.d/hbase.conf') do
    it { should exist }
    its('content') { should include 'hbase soft nofile' }
    its('content') { should include 'hbase hard nofile' }
  end
end

# Installation
control 'hbase-3.0' do
  impact 1.0
  title 'HBase Installation'
  desc 'Validates that HBase is properly installed'

  # Check for installation
  describe file('/opt/hbase/current') do
    it { should be_symlink }
  end

  describe command('ls -la /opt/hbase/current') do
    its('stdout') { should match /hbase-/ }
    its('exit_status') { should eq 0 }
  end
end

# Services
control 'hbase-4.0' do
  impact 1.0
  title 'HBase Services'
  desc 'Validates that HBase services are properly configured'

  # Check for systemd service definition
  describe file('/etc/systemd/system/hbase-master.service') do
    it { should exist }
    its('content') { should include 'Description=Apache HBase Master' }
    its('content') { should include 'ExecStart=' }
  end
end