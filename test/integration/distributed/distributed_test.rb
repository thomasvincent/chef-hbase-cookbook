# InSpec test for HBase in distributed mode

title 'HBase Distributed Mode Tests'

control 'hbase-distributed-1.0' do
  impact 1.0
  title 'HBase Distributed Configuration'
  desc 'Validates that HBase is properly configured for distributed mode'

  # Check configuration for distributed mode
  describe file('/etc/hbase/conf/hbase-site.xml') do
    it { should exist }
    its('content') { should include '<name>hbase.cluster.distributed</name>' }
    its('content') { should include '<value>true</value>' }
  end

  # Check for proper region server list
  describe file('/etc/hbase/conf/regionservers') do
    it { should exist }
    its('content') { should include 'localhost' }
  end

  # Check master-specific settings
  describe file('/etc/systemd/system/hbase-master.service') do
    it { should exist }
    its('content') { should include 'Description=Apache HBase Master Service' }
  end

  # Check master is running properly
  describe processes('java') do
    its('commands') { should include /org.apache.hadoop.hbase.master.HMaster/ }
  end

  # Master ports should be listening
  describe port(16000) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end

  describe port(16010) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end
end

control 'hbase-distributed-2.0' do
  impact 1.0
  title 'HBase Distributed ZooKeeper'
  desc 'Validates that ZooKeeper is properly configured for HBase'

  # Check for ZooKeeper data directory
  describe directory('/var/lib/zookeeper') do
    it { should exist }
    its('owner') { should eq 'hbase' }
    its('group') { should eq 'hbase' }
  end

  # Check if ZooKeeper is running as part of HBase
  describe processes('java') do
    its('commands') { should include /org.apache.zookeeper.server.quorum.QuorumPeerMain/ }
  end

  # ZooKeeper client port should be listening
  describe port(2181) do
    it { should be_listening }
    its('processes') { should include 'java' }
  end
end

control 'hbase-distributed-3.0' do
  impact 1.0
  title 'HBase Distributed Web UI'
  desc 'Validates that HBase web UI is accessible'

  # Check if web UI is accessible
  describe http('http://localhost:16010') do
    its('status') { should eq 200 }
    its('body') { should include 'HBase Master' }
  end
end
