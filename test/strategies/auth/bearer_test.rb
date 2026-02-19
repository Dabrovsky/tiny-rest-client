# frozen_string_literal: true

require "test_helper"

describe Strategies::Auth::Bearer do
  describe "#execute" do
    it "adds the correct Authorization header" do
      bearer = Strategies::Auth::Bearer.new(token: "abc123")
      request = FakeRequest.new

      bearer.execute(request)

      assert_equal "Bearer abc123", request.headers["Authorization"]
      assert_empty request.params
    end
  end

  describe "initialization" do
    it "raises ArgumentError when token is missing" do
      exception = assert_raises(ArgumentError) do
        Strategies::Auth::Bearer.new
      end

      assert_match(/Missing token parameter/, exception.message)
    end
  end
end
