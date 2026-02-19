# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "minitest/autorun"
require "tiny_rest_client"
require "support/fake_request"
require "support/request_stubbing"
