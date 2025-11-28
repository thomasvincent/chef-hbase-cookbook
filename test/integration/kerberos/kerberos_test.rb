# InSpec test for HBase cookbook with Kerberos authentication

title 'HBase with Kerberos Authentication Tests'

# Kerberos Configuration
control 'hbase-kerberos-1.0' do
  impact 1.0
  title 'Kerberos Configuration'
  desc 'Validates that Kerberos configuration is properly set up'

  describe file('/etc/hbase/conf/jaas.conf') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0600' }
    its('content') { should include 'com.sun.security.auth.module.Krb5LoginModule' }
    its('content') { should include 'useKeyTab=true' }
    its('content') { should include 'storeKey=true' }
  end

  describe file('/etc/hbase/conf/hbase-site.xml') do
    it { should exist }
    its('content') { should include '<name>hbase.security.authentication</name>' }
    its('content') { should include '<value>kerberos</value>' }
    its('content') { should include '<name>hbase.security.authorization</name>' }
  end

  # Check for keytab
  describe file('/etc/hbase/conf/hbase.keytab') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0400' }
  end
end

# Security Environment
control 'hbase-kerberos-2.0' do
  impact 1.0
  title 'Security Environment'
  desc 'Validates that security environment is properly configured'

  describe file('/etc/hbase/conf/hbase-env.sh') do
    it { should exist }
    its('content') { should include 'java.security.auth.login.config=' }
  end

  describe command('/opt/hbase/current/bin/hbase classpath') do
    its('stdout') { should match /hadoop-auth/ }
    its('exit_status') { should eq 0 }
  end
end

# Service Security Integration
control 'hbase-kerberos-3.0' do
  impact 1.0
  title 'Service Security Integration'
  desc 'Validates that services are properly configured for security'

  describe file('/etc/systemd/system/hbase-master.service') do
    it { should exist }
    its('content') { should include 'HBASE_OPTS=' }
    its('content') { should include 'java.security.auth.login.config=' }
  end

  # Check for secure ports
  describe port(16000) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end

  # HBase Master UI should be secure
  describe port(16010) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end
end
