# InSpec test for HBase cookbook
# Modern profile with enhanced compliance checks

title 'Apache HBase Cookbook Integration Tests'
maintainer 'Thomas Vincent'
copyright 'Thomas Vincent'
license 'Apache-2.0'

# Compliance profile metadata
only_if do
  # Skip some tests on Windows
  !os.windows?
end

# Basic System Configuration
control 'hbase-1.0' do
  impact 1.0
  title 'HBase system user and directories'
  desc 'Validates the HBase system user, groups and directories comply with security best practices'
  ref 'CIS Apache Hadoop Benchmark', url: 'https://www.cisecurity.org/'
  ref 'NIST SP 800-171', url: 'https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-171r2.pdf'
  tag 'security'
  tag 'identity'
  tag 'filesystem'
  
  # Check for user/group
  describe user('hbase') do
    it { should exist }
    its('uid') { should eq 2313 }
    its('group') { should eq 'hbase' }
    its('home') { should eq '/home/hbase' }
    its('shell') { should match /(\/bin\/bash|\/bin\/sh|\/sbin\/nologin)/ }
  end

  describe group('hbase') do
    it { should exist }
    its('gid') { should eq 2313 }
  end

  # Check for directories with enhanced security checks
  %w(/opt/hbase /etc/hbase/conf /var/log/hbase /var/run/hbase).each do |dir|
    describe directory(dir) do
      it { should exist }
      its('owner') { should eq 'hbase' }
      its('group') { should eq 'hbase' }
      its('mode') { should cmp '0755' }
      # Verify no world-writable directories
      it { should_not be_writable.by('others') }
    end
  end
end

# Configuration Files
control 'hbase-2.0' do
  impact 1.0
  title 'HBase configuration files'
  desc 'Validates that all required configuration files exist with correct ownership and permissions'
  ref 'Apache HBase Security', url: 'https://hbase.apache.org/book.html#security'
  tag 'configuration'
  tag 'security'

  # Check for configuration files with additional security validations
  describe file('/etc/hbase/conf/hbase-site.xml') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0644' }
    it { should_not be_writable.by('others') }
    its('content') { should match /<name>hbase\.rootdir<\/name>/ }
    # Validate essential configuration properties
    its('content') { should match /<name>hbase\.zookeeper\.quorum<\/name>/ }
  end

  describe file('/etc/hbase/conf/hbase-env.sh') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0644' }
    it { should_not be_writable.by('others') }
    its('content') { should match /JAVA_HOME=/ }
    its('content') { should match /HBASE_LOG_DIR=/ }
    # Verify secure garbage collection options
    its('content') { should match /-XX:\+UseG1GC/ }
  end

  describe file('/etc/hbase/conf/log4j2.properties') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0644' }
    it { should_not be_writable.by('others') }
    # Verify proper log levels
    its('content') { should match /rootLogger\.level\s*=\s*(INFO|WARN)/ }
  end

  describe file('/etc/hbase/conf/regionservers') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    its('mode') { should cmp '0644' }
    it { should_not be_writable.by('others') }
    its('content') { should include 'localhost' }
  end

  describe file('/etc/security/limits.d/hbase.conf') do
    it { should exist }
    it { should_not be_writable.by('others') }
    its('content') { should match /hbase\s+soft\s+nofile\s+\d+/ }
    its('content') { should match /hbase\s+hard\s+nofile\s+\d+/ }
    its('content') { should match /hbase\s+soft\s+nproc\s+\d+/ }
    its('content') { should match /hbase\s+hard\s+nproc\s+\d+/ }
  end

  # XML validation
  describe command('xmllint --noout /etc/hbase/conf/hbase-site.xml') do
    its('exit_status') { should eq 0 }
  end
end

# Installation
control 'hbase-3.0' do
  impact 1.0
  title 'HBase Installation'
  desc 'Validates that HBase is properly installed and configured'
  tag 'installation'
  
  # Check for installation
  describe file('/opt/hbase/current') do
    it { should be_symlink }
    its('link_path') { should match /\/opt\/hbase\/hbase-[0-9.]+/ }
  end

  # Check the actual version matches what we expect
  describe command('ls -la /opt/hbase/current') do
    its('stdout') { should match /hbase-[0-9.]+/ }
    its('exit_status') { should eq 0 }
  end

  # Verify installation contains expected files
  %w(bin/hbase bin/hbase-daemon.sh conf).each do |path|
    describe file("/opt/hbase/current/#{path}") do
      it { should exist }
    end
  end

  # Verify script permissions
  describe file('/opt/hbase/current/bin/hbase') do
    it { should be_executable.by('owner') }
    its('mode') { should cmp '0755' }
  end
end

# Java Installation
control 'hbase-4.0' do
  impact 1.0
  title 'Java Installation for HBase'
  desc 'Validates that a compatible Java version is installed and properly configured for HBase'
  tag 'java'
  tag 'runtime'
  
  # Check Java installation
  describe command('java -version') do
    its('exit_status') { should eq 0 }
    # HBase officially supports Java 8, with preliminary support for Java 11 and 17
    its('stderr') { should match /(openjdk|jdk) version "(1\.8|8|11|17)"/ }
  end
  
  # Check JAVA_HOME environment
  describe file('/etc/profile.d/java_home.sh') do
    it { should exist }
    its('mode') { should cmp '0755' }
    its('content') { should match /export JAVA_HOME=/ }
  end
  
  # Verify Java security - don't allow weak ciphers if in secure mode
  if file('/etc/hbase/conf/hbase-site.xml').content =~ /hbase\.security\.authentication.*kerberos/
    describe command('$JAVA_HOME/bin/java -XshowSettings:properties -version 2>&1 | grep "java.security"') do
      its('stdout') { should_not include 'SSLv3' }
      its('stdout') { should_not include 'TLSv1' }
      its('stdout') { should_not include 'TLSv1.1' }
    end
  end
end

# Services
control 'hbase-5.0' do
  impact 1.0
  title 'HBase Services'
  desc 'Validates that HBase services are properly configured and running'
  tag 'services'
  tag 'runtime'

  # Check for systemd service definition
  describe file('/etc/systemd/system/hbase-master.service') do
    it { should exist }
    its('content') { should include 'Description=Apache HBase Master' }
    its('content') { should include 'ExecStart=' }
    # Ensure proper start dependencies
    its('content') { should include 'After=network.target' }
  end
  
  # Check process is running (if enabled)
  # Only check if service is running for master role
  if file('/etc/hbase/conf/hbase-site.xml').content =~ /hbase\.cluster\.distributed.*true/ && 
     file('/opt/hbase/current/conf/backup-masters').exist?

    # Check service status using systemctl
    describe service('hbase-master') do
      it { should be_installed }
      it { should be_enabled }
      it { should be_running }
    end

    # Check process is running with proper user
    describe processes('HMaster') do
      its('users') { should eq ['hbase'] }
    end
  end
end

# Network Configuration
control 'hbase-6.0' do
  impact 1.0
  title 'HBase Network Configuration'
  desc 'Validates that HBase ports are properly configured and listening as expected'
  tag 'network'
  tag 'security'
  
  # Only check network ports if running in distributed mode
  if file('/etc/hbase/conf/hbase-site.xml').content =~ /hbase\.cluster\.distributed.*true/
    # Standard HBase ports - master
    [16000, 16010].each do |port|
      describe port(port) do
        it { should be_listening }
        its('protocols') { should include 'tcp' }
      end
    end
    
    # Check if the process is listening only on appropriate addresses
    describe command('netstat -tulpn | grep HMaster') do
      its('stdout') { should match /(127\.0\.0\.1|0\.0\.0\.0|::)/ }
    end
  end
  
  # Check for sensitive ports that shouldn't be open externally
  describe port(22) do
    its('processes') { should_not include 'java' }
  end
end

# Security Configuration
control 'hbase-7.0' do
  impact 1.0
  title 'HBase Security Configuration'
  desc 'Validates security settings for HBase if enabled'
  tag 'security'
  tag 'authentication'
  
  # Only check security settings if security is enabled
  if file('/etc/hbase/conf/hbase-site.xml').content =~ /hbase\.security\.authentication.*kerberos/
    # Check Kerberos configuration
    describe file('/etc/hbase/conf/jaas.conf') do
      it { should exist }
      its('mode') { should cmp '0640' }
      it { should_not be_readable.by('others') }
      its('content') { should match /com\.sun\.security\.auth\.module\.Krb5LoginModule/ }
    end
    
    # Check keytab file
    keytab_path = command("grep -A1 'hbase.master.keytab.file' /etc/hbase/conf/hbase-site.xml | grep 'value' | sed -e 's/.*<value>\\(.*\\)<\\/value>.*/\\1/'").stdout.strip
    if !keytab_path.empty?
      describe file(keytab_path) do
        it { should exist }
        its('mode') { should cmp '0400' }
        it { should_not be_readable.by('group') }
        it { should_not be_readable.by('others') }
        its('owner') { should eq 'hbase' }
      end
    end
  end
end

# Log Configuration
control 'hbase-8.0' do
  impact 0.8
  title 'HBase Log Configuration'
  desc 'Validates that logs are properly configured and rotated'
  tag 'logging'
  
  # Check log directory
  describe directory('/var/log/hbase') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
    it { should_not be_readable.by('others') }
  end
  
  # Check log files are properly owned
  command('find /var/log/hbase -type f -name "*.log" -o -name "*.out"').stdout.split.each do |log_file|
    describe file(log_file) do
      it { should exist }
      its('owner') { should eq 'hbase' }
      its('group') { should eq 'hbase' }
      it { should_not be_writable.by('others') }
      it { should_not be_readable.by('others') }
    end
  end
  
  # Check log rotation configuration
  if os.family == 'debian' || os.family == 'ubuntu'
    describe file('/etc/logrotate.d/hbase') do
      it { should exist }
      its('content') { should match /\/var\/log\/hbase/ }
      its('content') { should match /rotate/ }
    end
  end
end