# CLAUDE.md

Chef cookbook for Apache HBase, the Hadoop database.

## Stack
- Ruby / Chef 18.0+
- Test Kitchen + InSpec
- Docker/Dokken for testing

## Lint & Test
```bash
cookstyle .
kitchen test
```

## Notes
- Supports standalone and distributed modes with Master/RegionServer roles
- Full Kerberos security integration with keytab management
- Includes REST/Thrift services and metrics collection (Prometheus, Graphite)
