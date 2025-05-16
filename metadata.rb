name             'hbase'
maintainer       'Thomas Vincent'
maintainer_email 'thomasvincent@github.com'
license          'Apache-2.0'
description      'Installs/Configures Apache HBase'
version          '1.1.0'
chef_version     '>= 18.0'

supports 'ubuntu', '>= 20.04'
supports 'debian', '>= 11.0'
supports 'centos', '>= 8.0'
supports 'redhat', '>= 8.0'
supports 'amazon', '>= 2.0'
supports 'fedora', '>= 36.0'

depends 'ark', '~> 5.0'

issues_url 'https://github.com/thomasvincent/chef-hbase-cookbook/issues'
source_url 'https://github.com/thomasvincent/chef-hbase-cookbook'