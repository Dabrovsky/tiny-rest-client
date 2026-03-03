# frozen_string_literal: true

require "test_helper"
require "generators/tiny_rest_client/client_generator"

module TinyRestClient
  module Generators
    class ClientGeneratorTest < Rails::Generators::TestCase
      tests TinyRestClient::Generators::ClientGenerator
      destination File.expand_path("../../dummy", __dir__)
      setup :prepare_destination

      teardown do
        FileUtils.rm_rf(destination_root)
      end

      test "generates basic client file" do
        run_generator %w[dummy]

        assert_file "app/clients/dummy_client.rb" do |content|
          assert_match "class DummyClient < TinyRestClient::Core", content
          assert_match 'api_path "your_api_path"', content
        end
      end

      test "generator creates nested client file" do
        run_generator %w[api/dummy]

        assert_file "app/clients/api/dummy_client.rb" do |content|
          assert_match "class Api::DummyClient < TinyRestClient::Core", content
          assert_match 'api_path "your_api_path"', content
        end
      end

      test "generator respects api-path argument" do
        run_generator %w[dummy https://dummy.com/v1]

        assert_file "app/clients/dummy_client.rb" do |content|
          assert_match 'api_path "https://dummy.com/v1"', content
        end
      end

      test "generator respects --namespace option" do
        run_generator %w[dummy --namespace=example]

        assert_file "app/example/dummy_client.rb" do |content|
          assert_match 'api_path "your_api_path"', content
        end
      end

      test "generator creates test file (Minitest)" do
        run_generator %w[dummy]

        assert_file "test/clients/dummy_client_test.rb" do |content|
          assert_match "class DummyClientTest < ActiveSupport::TestCase", content
        end
      end
    end
  end
end
