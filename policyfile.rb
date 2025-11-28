# Policyfile.rb - Describe how you want Chef Infra Client to build your system.

name 'hbase'
default_source :supermarket
run_list 'hbase::default'
cookbook 'hbase', path: '.'
cookbook 'ark', '~> 5.0.0'
