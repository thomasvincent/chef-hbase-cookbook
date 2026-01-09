# Basic configuration
default['hbase']['version'] = '2.4.0'
default['hbase']['mirror'] = 'https://downloads.apache.org/hbase'
default['hbase']['checksum'] = nil # Set specific version checksum here
default['hbase']['install_dir'] = '/opt/hbase'
default['hbase']['conf_dir'] = '/etc/hbase/conf'
default['hbase']['log_dir'] = '/var/log/hbase'
default['hbase']['pid_dir'] = '/var/run/hbase'
default['hbase']['user'] = 'hbase'
default['hbase']['group'] = 'hbase'
default['hbase']['uid'] = 2313
default['hbase']['gid'] = 2313
default['hbase']['log_level'] = 'INFO'

# Java options - HBase officially supports Java 8, with preliminary support for Java 11 and 17
default['hbase']['java']['version'] = '11'
default['hbase']['java_home'] = nil # Will be auto-detected based on platform and version
default['hbase']['java_opts'] = '-Xmx1024m -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200'

# System limits
default['hbase']['limits']['nofile'] = 32_768
default['hbase']['limits']['nproc'] = 65_536

# Installation options
default['hbase']['install']['method'] = 'binary' # 'binary' or 'package'
default['hbase']['install']['packages'] = [] # For package installation method

# Topology settings
default['hbase']['topology']['role'] = nil # Can be 'master', 'regionserver', 'backup_master', or nil for standalone
default['hbase']['topology']['quorum_members'] = [] # Nodes that should run ZooKeeper
default['hbase']['topology']['masters'] = [] # Nodes that should run HBase master
default['hbase']['topology']['regionservers'] = [] # Nodes that should run HBase region servers

# Essential HBase configuration
default['hbase']['config']['hbase.rootdir'] = 'file:///var/hbase'
default['hbase']['config']['hbase.zookeeper.quorum'] = 'localhost'
default['hbase']['config']['hbase.zookeeper.property.dataDir'] = '/var/lib/zookeeper'
default['hbase']['config']['hbase.cluster.distributed'] = false
default['hbase']['config']['hbase.zookeeper.property.clientPort'] = 2181

# Advanced HBase configuration
default['hbase']['config']['hbase.master.port'] = 16000
default['hbase']['config']['hbase.master.info.port'] = 16010
default['hbase']['config']['hbase.regionserver.port'] = 16020
default['hbase']['config']['hbase.regionserver.info.port'] = 16030
default['hbase']['config']['hbase.rest.port'] = 8080
default['hbase']['config']['hbase.rest.info.port'] = 8085
default['hbase']['config']['hbase.thrift.port'] = 9090
default['hbase']['config']['hbase.thrift.info.port'] = 9095
default['hbase']['config']['hbase.regionserver.handler.count'] = 30
default['hbase']['config']['hbase.hregion.memstore.flush.size'] = 134_217_728 # 128MB
default['hbase']['config']['hbase.hregion.max.filesize'] = 10_737_418_240 # 10GB
default['hbase']['config']['hbase.hstore.blockingStoreFiles'] = 10
default['hbase']['config']['hbase.hstore.compactionThreshold'] = 3
default['hbase']['config']['hbase.hstore.compaction.max'] = 10
default['hbase']['config']['hbase.client.scanner.caching'] = 100
default['hbase']['config']['hbase.client.scanner.timeout.period'] = 60000
default['hbase']['config']['hbase.client.retries.number'] = 35
default['hbase']['config']['hbase.client.pause'] = 100
default['hbase']['config']['hbase.client.max.perserver.tasks'] = 2
default['hbase']['config']['hbase.defaults.for.version.skip'] = true

# Performance tuning
default['hbase']['config']['hbase.ipc.server.read.threadpool.size'] = 10
default['hbase']['config']['hbase.server.thread.wakefrequency'] = 10000
default['hbase']['config']['hbase.server.versionfile.writeattempts'] = 3
default['hbase']['config']['hbase.rpc.timeout'] = 60000
default['hbase']['config']['hbase.regions.slop'] = 0.2

# Security configuration
default['hbase']['security']['authentication'] = 'simple' # 'simple' or 'kerberos'
default['hbase']['security']['authorization'] = false
default['hbase']['security']['superuser'] = 'hbase'
default['hbase']['security']['kerberos']['principal'] = 'hbase/_HOST'
default['hbase']['security']['kerberos']['keytab'] = '/etc/hbase/conf/hbase.keytab'
default['hbase']['security']['kerberos']['realm'] = 'EXAMPLE.COM'
default['hbase']['security']['kerberos']['server_principal'] = 'hbase/_HOST@EXAMPLE.COM'
default['hbase']['security']['kerberos']['regionserver_principal'] = 'hbase/_HOST@EXAMPLE.COM'

# HDFS settings if using HDFS
default['hbase']['hadoop']['version'] = '3.3.5'
default['hbase']['hadoop']['hdfs_site'] = {}
default['hbase']['hadoop']['core_site'] = {}

# Optional HBase Services
default['hbase']['services']['thrift']['enabled'] = false
default['hbase']['services']['thrift']['config'] = {}
default['hbase']['services']['rest']['enabled'] = false
default['hbase']['services']['rest']['config'] = {}

# Metrics and monitoring
default['hbase']['metrics']['enabled'] = false
default['hbase']['metrics']['provider'] = 'prometheus' # 'prometheus' or 'graphite'
default['hbase']['metrics']['prometheus']['port'] = 9090
default['hbase']['metrics']['graphite']['host'] = 'localhost'
default['hbase']['metrics']['graphite']['port'] = 2003
default['hbase']['metrics']['graphite']['prefix'] = 'hbase'
default['hbase']['metrics']['period'] = 10

# Coprocessors
default['hbase']['coprocessors'] = []

# Custom service mappings
default['hbase']['service_mapping'] = {
  'master' => {
    'service_name' => 'master',
    'start_priority' => 10,
    'conf_file' => 'hbase-site.xml',
  },
  'regionserver' => {
    'service_name' => 'regionserver',
    'start_priority' => 20,
    'conf_file' => 'hbase-site.xml',
  },
  'thrift' => {
    'service_name' => 'thrift',
    'start_priority' => 30,
    'conf_file' => 'hbase-site.xml',
  },
  'rest' => {
    'service_name' => 'rest',
    'start_priority' => 40,
    'conf_file' => 'hbase-site.xml',
  },
}
