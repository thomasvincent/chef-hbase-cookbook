# HBase Cookbook Changelog

This file tracks the changes in the HBase cookbook over time.

## 1.1.0 (2024-05-09)

- Enhanced Java compatibility for HBase
- Added dedicated java recipe for platform-specific Java installation
- Updated to support Java 8, 11, and 17 based on HBase compatibility
- Improved Java home auto-detection based on OS platform
- Updated integration tests for Java compatibility
- Removed dependency on the java cookbook for more direct control
- Enhanced documentation for Java version support
- Added Test Kitchen tests for Java compatibility
- Updated to HBase 2.5.11 (latest stable version)
- Updated Hadoop version to 3.3.5

## 1.0.0 (2023-05-10)

- Initial release with modern Chef 17+ support
- Comprehensive implementation of HBase with Docker testing
- Support for distributed and standalone deployments
- Custom resources for service and configuration management
- GitHub Actions CI integration
- Support for latest platforms: Ubuntu 20.04/22.04, Debian 11+, AlmaLinux/RHEL 8/9, Amazon Linux 2, Fedora 36+
- Enhanced security features including Kerberos integration
- REST and Thrift API support
- Metrics collection capabilities (Prometheus, Graphite)
- Performance tuning options
- Advanced configuration options