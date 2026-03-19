# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-03-19

### Added
- Class-level retries with configurable delay (throttling)
  - `retries 3, delay: 0.5` - retry 3 times on 5xx errors with 500ms delay between attempts
  - Default retryable codes: 500, 502, 503, 504
  - Instance-level override supported

## [0.2.1] - 2026-03-03

### Fixed
- Ensure the gem can be required without `require:` option in Gemfile
- Add `lib/tiny-rest-client.rb` loader file for RubyGems auto-require compatibility

## [0.2.0] - 2026-03-03

### Added
- Rails generator `tiny_rest_client:client` for scaffolding API client classes
  - Supports nested client names (e.g. `api/v1/stripe`)
  - Optional base URL argument
  - Configurable root namespace via `--namespace`

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

[0.3.0]: https://github.com/Dabrovsky/tiny-rest-client/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/Dabrovsky/tiny-rest-client/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/Dabrovsky/tiny-rest-client/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/Dabrovsky/tiny-rest-client/releases/tag/v0.1.0
