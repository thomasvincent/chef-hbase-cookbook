# InSpec test for HBase REST API service

title 'HBase REST API Service Tests'

control 'hbase-rest-1.0' do
  impact 1.0
  title 'HBase REST Service'
  desc 'Validates that the HBase REST service is properly configured and running'

  # Check configuration
  describe file('/etc/hbase/conf/hbase-site.xml') do
    it { should exist }
    its('content') { should include '<name>hbase.rest.port</name>' }
    its('content') { should include '<value>8080</value>' }
  end

  # Check for systemd service definition
  describe file('/etc/systemd/system/hbase-rest.service') do
    it { should exist }
    its('content') { should include 'Description=Apache HBase REST Service' }
    its('content') { should include 'ExecStart=' }
    its('content') { should include 'rest' }
  end
  
  # Check if REST process is running
  describe processes('java') do
    its('commands') { should include /org.apache.hadoop.hbase.rest.RESTServer/ }
  end

  # REST API port should be listening
  describe port(8080) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end

  # REST info/admin port should be listening
  describe port(8085) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end

  # Check if we can access the REST API
  describe http('http://localhost:8080/version') do
    its('status') { should eq 200 }
    its('body') { should include 'rest' }
  end

  # Check if we can access the REST info page
  describe http('http://localhost:8085') do
    its('status') { should eq 200 }
    its('body') { should include 'REST' }
  end
end