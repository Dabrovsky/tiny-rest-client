# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-22

### Added
- First public release
- Core client class with DSL for api_path and authorization
- Authorization strategies:
  - Bearer
  - API Key with configurable location and name
  - Basic Auth
- Request wrapper class around Typhoeus
- Simple success/failure response helpers
- Full Minitest suite (classic + spec style examples)
- Basic README documentation

[Unreleased]: https://github.com/Dabrovsky/tiny_rest_client/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Dabrovsky/tiny_rest_client/releases/tag/v0.1.0
