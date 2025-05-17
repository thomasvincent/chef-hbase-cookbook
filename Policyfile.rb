# Policyfile.rb - Policyfile for the HBase cookbook
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'hbase'

# Where to find external cookbooks:
default_source :supermarket

# Run list for when using this Policyfile
run_list 'hbase::default'

# Specify a version constraint for each cookbook (including transitive ones)
# if not using the latest version from Supermarket.
cookbook 'hbase', path: '.'
cookbook 'ark', '~> 5.0'

# Attributes
default['hbase']['version'] = '2.5.11'
default['hbase']['install']['method'] = 'binary'
default['hbase']['java']['version'] = '11'