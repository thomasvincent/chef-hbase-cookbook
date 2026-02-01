name             'hbase'
maintainer       'Thomas Vincent'
maintainer_email 'thomasvincent@github.com'
license          'Apache-2.0'
description      'Installs/Configures Apache HBase'
version          '1.1.0'
chef_version     '>= 18.0'

# Supported platforms - tested with Docker/Dokken
supports 'ubuntu', '>= 22.04'
supports 'debian', '>= 12.0'
supports 'redhat', '>= 9.0'
supports 'rocky', '>= 9.0'
supports 'amazon', '>= 2023.0'

depends 'ark', '~> 5.0'

issues_url 'https://github.com/thomasvincent/chef-hbase-cookbook/issues'
source_url 'https://github.com/thomasvincent/chef-hbase-cookbook'
