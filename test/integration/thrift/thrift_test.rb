# InSpec test for HBase Thrift service

title 'HBase Thrift Service Tests'

control 'hbase-thrift-1.0' do
  impact 1.0
  title 'HBase Thrift Service'
  desc 'Validates that the HBase Thrift service is properly configured and running'

  # Check configuration
  describe file('/etc/hbase/conf/hbase-site.xml') do
    it { should exist }
    its('content') { should include '<name>hbase.thrift.port</name>' }
    its('content') { should include '<value>9090</value>' }
  end

  # Check for systemd service definition
  describe file('/etc/systemd/system/hbase-thrift.service') do
    it { should exist }
    its('content') { should include 'Description=Apache HBase Thrift Service' }
    its('content') { should include 'ExecStart=' }
    its('content') { should include 'thrift' }
  end
  
  # Check if Thrift process is running
  describe processes('java') do
    its('commands') { should include /org.apache.hadoop.hbase.thrift.ThriftServer/ }
  end

  # Thrift server port should be listening
  describe port(9090) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end

  # Thrift info port should be listening
  describe port(9095) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end

  # Check if we can access the Thrift info page
  describe http('http://localhost:9095') do
    its('status') { should eq 200 }
    its('body') { should include 'Thrift' }
  end
end