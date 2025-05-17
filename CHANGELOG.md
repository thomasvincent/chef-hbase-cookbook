# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2023-07-11

### Added
- Automated semantic versioning via GitHub Actions workflow
- Release workflow for GitHub Packages integration
- Compatibility matrix for supported platforms
- Enhanced InSpec tests with security compliance checks
- Support for Chef Infra Client 18+ compatibility
- Expanded platform support including macOS, Windows, and FreeBSD

### Changed
- Modernized CI workflow with matrix testing 
- Updated README with comprehensive platform support information
- Improved documentation for Policyfile usage
- Updated CODEOWNERS file for GitHub repository management

## [1.1.0] - 2024-05-09

### Added
- Enhanced Java compatibility for HBase
- Added dedicated java recipe for platform-specific Java installation
- Support for Java 8, 11, and 17 based on HBase compatibility
- Improved Java home auto-detection based on OS platform

### Changed
- Updated integration tests for Java compatibility
- Removed dependency on the java cookbook for more direct control
- Enhanced documentation for Java version support
- Updated to HBase 2.5.11 (latest stable version)
- Updated Hadoop version to 3.3.5

## [1.0.0] - 2023-05-10

### Added
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