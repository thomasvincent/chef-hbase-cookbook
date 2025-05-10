name             'hbase'
maintainer       'Thomas Vincent'
maintainer_email 'thomasvincent@github.com'
license          'Apache-2.0'
description      'Installs/Configures Apache HBase'
version          '1.0.0'
chef_version     '>= 16.0'

supports 'ubuntu', '>= 20.04'
supports 'debian', '>= 11.0'
supports 'centos', '>= 8.0'
supports 'amazon'

depends 'java'
depends 'ark', '~> 5.0'

source_url 'https://github.com/thomasvincent/chef-hbase-cookbook'
issues_url 'https://github.com/thomasvincent/chef-hbase-cookbook/issues'