# frozen_string_literal: true

require "minitest/autorun"
require "rails/generators/test_case"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "support/fake_request"
require "support/request_stubbing"
require "tiny_rest_client"

require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
