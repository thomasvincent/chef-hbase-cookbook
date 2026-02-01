# chef-hbase-cookbook

## Purpose
Chef cookbook to install and configure Apache HBase (standalone or distributed) with support for Master, RegionServer, REST/Thrift services, Kerberos, and metrics.

## Stack
- Chef 18+ / Ruby
- ChefSpec (unit), Test Kitchen with kitchen-dokken (integration)
- Policyfile for dependency management
- Depends on `ark` cookbook

## Build / Test
```bash
bundle install
bundle exec cookstyle          # Lint
bundle exec rspec              # ChefSpec unit tests
bundle exec kitchen test       # Integration tests (Docker)
```

## Standards
- Unified mode for custom resources
- Guard properties on all `execute` resources
- ChefSpec tests in `spec/`, InSpec tests in `test/`
- Cookstyle clean
- Custom resources in `resources/`
