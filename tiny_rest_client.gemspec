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

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[.gitignore test/ .rubocop.yml Gemfile])
    end
  end
  spec.files += %w[README.md LICENSE]
  spec.require_paths = ["lib"]

  spec.add_dependency "typhoeus", "~> 1.4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
