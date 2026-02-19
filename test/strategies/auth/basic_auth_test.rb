# frozen_string_literal: true

require "test_helper"

describe Strategies::Auth::BasicAuth do
  describe "#execute" do
    it "adds the correct userpwd to rest options" do
      basic_auth = Strategies::Auth::BasicAuth.new(user: "user", password: "password")
      request = FakeRequest.new

      basic_auth.execute(request)

      assert_equal "user:password", request.rest[:userpwd]
      assert_empty request.params
    end
  end

  describe "initialization" do
    it "raises ArgumentError when user is missing" do
      exception = assert_raises(ArgumentError) do
        Strategies::Auth::BasicAuth.new
      end

      assert_match(/Missing user parameter/, exception.message)
    end

    it "raises ArgumentError when password is missing" do
      exception = assert_raises(ArgumentError) do
        Strategies::Auth::BasicAuth.new(user: "user")
      end

      assert_match(/Missing password parameter/, exception.message)
    end
  end
end
