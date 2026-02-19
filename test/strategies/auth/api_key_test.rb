# frozen_string_literal: true

require "test_helper"

describe Strategies::Auth::ApiKey do
  describe "initialization" do
    it "accepts all options and sets them correctly" do
      api_key = Strategies::Auth::ApiKey.new(
        token: "abc123",
        in: :query,
        name: "my_key"
      )

      assert_equal "abc123", api_key.token
      assert_equal :query, api_key.location
      assert_equal "my_key", api_key.name
    end

    it "uses correct defaults when options are omitted" do
      api_key = Strategies::Auth::ApiKey.new(token: "abc123")

      assert_equal :header, api_key.location
      assert_equal "X-API-Key", api_key.name
    end

    it "raises ArgumentError when token is missing" do
      exception = assert_raises(ArgumentError) do
        Strategies::Auth::ApiKey.new
      end

      assert_match(/Missing token parameter/, exception.message)
    end
  end

  describe "#execute" do
    it "adds the key to headers when location is :header" do
      api_key = Strategies::Auth::ApiKey.new(token: "abc123")
      request = FakeRequest.new

      api_key.execute(request)

      assert_equal "abc123", request.headers["X-API-Key"]
      assert_empty request.params
    end

    it "adds the key as query parameter when location is :query" do
      api_key = Strategies::Auth::ApiKey.new(token: "abc123", in: :query)
      request = FakeRequest.new

      api_key.execute(request)

      assert_equal "abc123", request.params["api_key"]
      assert_empty request.headers
    end

    it "raises ArgumentError for invalid location" do
      api_key = Strategies::Auth::ApiKey.new(token: "abc123", in: :cookie)
      request = FakeRequest.new

      exception = assert_raises(ArgumentError) do
        api_key.execute(request)
      end

      assert_match(/Invalid key/, exception.message)
    end
  end
end
