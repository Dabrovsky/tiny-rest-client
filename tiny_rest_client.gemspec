# frozen_string_literal: true

require_relative "lib/tiny_rest_client/version"

Gem::Specification.new do |spec|
  spec.name = "tiny-rest-client"
  spec.version = TinyRestClient::VERSION
  spec.authors = ["Dabrovski"]
  spec.email = ["wojciech.dabrovski@gmail.com"]

  spec.summary = "A minimal REST client gem for Rails"
  spec.description = "A lightweight, Ruby-friendly HTTP client that makes HTTP requests simple and easy to use."
  spec.homepage = "https://github.com/Dabrovsky/tiny-rest-client"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Dabrovsky/tiny-rest-client"
  spec.metadata["changelog_uri"] = "https://github.com/Dabrovsky/tiny-rest-client/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.require_paths = ["lib"]
  spec.files = Dir[
    "lib/**/*.rb",
    "lib/generators/**/*.rb",
    "lib/generators/**/*.tt",
    "LICENSE",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.add_dependency "typhoeus", "~> 1.4"
end
