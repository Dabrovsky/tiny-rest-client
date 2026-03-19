# frozen_string_literal: true

require "test_helper"

describe TinyRestClient do
  include RequestStubbing

  before do
    TinyRestClient::Core.instance_variable_set(:@api_path, nil)
    TinyRestClient::Core.instance_variable_set(:@auth_config, nil)
    TinyRestClient::Core.instance_variable_set(:@headers, nil)
    TinyRestClient::Core.instance_variable_set(:@retry_options, nil)
    Typhoeus::Expectation.clear
  end

  it "has a version number" do
    refute_nil TinyRestClient::VERSION
  end

  describe ".api_path" do
    it "sets and returns the api_path correctly" do
      TinyRestClient::Core.api_path "https://example.com"
      assert_equal "https://example.com", TinyRestClient::Core.api_path
    end

    it "raises missing API path" do
      error = assert_raises(ArgumentError) do
        TinyRestClient::Core.new
      end

      assert_equal "Undefined api_path base URL", error.message
    end
  end

  describe ".authorization" do
    it "stores bearer configuration correctly" do
      TinyRestClient::Core.authorization :bearer, token: "abc123"

      expected = {
        bearer: {
          credentials: { token: "abc123" }
        }
      }

      assert_equal expected, TinyRestClient::Core.authorization
    end

    it "stores api_key configuration (header placement)" do
      TinyRestClient::Core.authorization :api_key, token: "abc123", in: :header, name: "X-Custom-Key"

      expected = {
        api_key: {
          credentials: {
            token: "abc123",
            in: :header,
            name: "X-Custom-Key"
          }
        }
      }

      assert_equal expected, TinyRestClient::Core.authorization
    end

    it "stores api_key configuration (query placement)" do
      TinyRestClient::Core.authorization :api_key, token: "abc123", in: :query, name: "apiKey"

      expected = {
        api_key: {
          credentials: {
            token: "abc123",
            in: :query,
            name: "apiKey"
          }
        }
      }

      assert_equal expected, TinyRestClient::Core.authorization
    end

    it "stores basic_auth configuration correctly" do
      TinyRestClient::Core.authorization :basic_auth, user: "alice", password: "secret99"

      expected = {
        basic_auth: {
          credentials: { user: "alice", password: "secret99" }
        }
      }

      assert_equal expected, TinyRestClient::Core.authorization
    end
  end

  describe ".header" do
    it "stores custom headers correctly" do
      TinyRestClient::Core.header "User-Agent", "MyTest/1.0"
      TinyRestClient::Core.header "Accept", "application/json"

      expected = {
        "User-Agent" => "MyTest/1.0",
        "Accept" => "application/json"
      }

      assert_equal expected, TinyRestClient::Core.headers
    end
  end

  describe ".headers" do
    it "stores custom headers correctly" do
      TinyRestClient::Core.headers "User-Agent": "MyTest/1.0", Accept: "application/json"

      expected = {
        "User-Agent" => "MyTest/1.0",
        "Accept" => "application/json"
      }

      assert_equal expected, TinyRestClient::Core.headers
    end
  end

  describe "#initialize" do
    it "raises ArgumentError when api_path is missing" do
      err = assert_raises(ArgumentError) do
        TinyRestClient::Core.new
      end

      assert_equal "Undefined api_path base URL", err.message
    end

    it "stores custom headers correctly" do
      client = TinyRestClient::Core.new(
        api_path: "https://test.com",
        headers: { "User-Agent": "MyTest/1.0", Accept: "application/json" }
      )

      expected = {
        "User-Agent" => "MyTest/1.0",
        "Accept" => "application/json"
      }

      assert_equal expected, client.headers
    end
  end

  describe "HTTP request methods" do
    let(:client) { TinyRestClient::Core.new(api_path: "https://api.test") }

    it "HEAD passes correct arguments to Request" do
      stub_request_with(:head, endpoint: "/users", expected_params: { limit: 10 }) do
        client.head("/users", limit: 10)
      end
    end

    it "GET passes correct arguments to Request" do
      stub_request_with(:get, endpoint: "/users", expected_params: { limit: 10 }) do
        client.get("/users", limit: 10)
      end
    end

    it "POST passes correct arguments to Request" do
      payload = { foo: "bar" }

      stub_request_with(:post, endpoint: "/users", expected_body: payload) do
        client.post("/users", payload)
      end
    end

    it "PATCH passes correct arguments to Request" do
      payload = { foo: "bar" }

      stub_request_with(:patch, endpoint: "/users", expected_body: payload) do
        client.patch("/users", payload)
      end
    end

    it "PUT passes correct arguments to Request" do
      payload = { foo: "bar" }

      stub_request_with(:put, endpoint: "/users", expected_body: payload) do
        client.put("/users", payload)
      end
    end

    it "DELETE passes correct arguments to Request" do
      stub_request_with(:delete, endpoint: "/users/1") do
        client.delete("/users/1")
      end
    end

    it "OPTIONS passes correct arguments to Request" do
      stub_request_with(:options, endpoint: "/users/1", expected_params: { cors: "check" }) do
        client.options("/users/1", cors: "check")
      end
    end
  end

  describe "failed requests" do
    let(:client) { TinyRestClient::Core.new(api_path: "https://api.test") }

    it "handles network failure error" do
      stub_request(code: 0, return_code: :couldnt_connect)
      response = client.get("/todos")

      assert response.failure?
      assert 0, response.code
      assert_equal :couldnt_connect, response.status
    end

    it "handles not found error" do
      stub_request(code: 404, return_code: :not_found, body: "Not found")
      response = client.get("/todos")

      assert response.failure?
      assert 404, response.code
      assert_equal :not_found, response.status
      assert "Not found", response.body
    end

    it "handles internal server error" do
      stub_request(code: 500, return_code: :internal_server_error, body: "Something went wrong")
      response = client.get("/todos")

      assert response.failure?
      assert 500, response.code
      assert_equal :internal_server_error, response.status
      assert "Something went wrong", response.body
    end

    it "handles request timeout" do
      stub_request(code: 0, return_code: :operation_timedout)
      response = client.get("/todos")

      assert response.failure?
      assert_equal 0, response.code
      assert_equal :operation_timedout, response.status
    end

    it "rescues standard error" do
      Typhoeus::Request.stub :new, ->(*) { raise Typhoeus::Errors::TyphoeusError, "Something went wrong" } do
        response = client.get("/todos")

        assert_equal "Something went wrong", response.body
        assert response.failure?
      end
    end
  end

  describe "retries" do
    let(:client) { TinyRestClient::Core.new(api_path: "https://api.test", retries: { count: 3, on: [503] }) }

    it "retries 3 times on 503 and succeeds on 4th" do
      mock_request = Minitest::Mock.new

      # Simulate 3 failures and 1 success
      mock_request.expect(:run, failure_response)
      mock_request.expect(:run, failure_response)
      mock_request.expect(:run, failure_response)
      mock_request.expect(:run, success_response)

      Typhoeus::Request.stub :new, ->(*) { mock_request } do
        resp = client.get("/todos")

        assert resp.success?
        assert_equal 200, resp.code
        assert_equal({ success: true }, resp.body)
      end

      mock_request.verify
    end

    it "does not retry on 400" do
      mock_request = Minitest::Mock.new
      mock_request.expect(:run, failure_response(400))

      Typhoeus::Request.stub :new, ->(*) { mock_request } do
        resp = client.get("/todos")
        refute resp.success?
        assert_equal 400, resp.code
      end

      mock_request.verify # only called once
    end

    it "retries on Typhoeus network error" do
      mock_request = Minitest::Mock.new

      mock_request.expect(:run, nil) { raise Typhoeus::Errors::TyphoeusError, "connection timeout" }
      mock_request.expect(:run, nil) { raise Typhoeus::Errors::TyphoeusError, "connection timeout" }
      mock_request.expect(:run, nil) { raise Typhoeus::Errors::TyphoeusError, "connection timeout" }
      mock_request.expect(:run, success_response)

      Typhoeus::Request.stub :new, ->(*) { mock_request } do
        resp = client.get("/todos")
        assert resp.success?
      end

      mock_request.verify
    end

    it "sleeps between retries" do
      mock_request = Minitest::Mock.new

      mock_request.expect(:run, failure_response)
      mock_request.expect(:run, failure_response)
      mock_request.expect(:run, failure_response)
      mock_request.expect(:run, failure_response)

      start_time = Time.now

      Typhoeus::Request.stub :new, ->(*) { mock_request } do
        client.get("/todos")
      end

      elapsed = Time.now - start_time

      # Default delay: 1s + 1s + 1s = ~3s total sleep
      assert elapsed > 2.9, "Expected default delay, got #{elapsed.round(2)}s"
    end

    it "uses custom delay" do
      client = TinyRestClient::Core.new(
        api_path: "https://api.test",
        retries: {
          count: 2,
          delay: 2.0
        }
      )

      mock_request = Minitest::Mock.new

      mock_request.expect(:run, failure_response)
      mock_request.expect(:run, failure_response)
      mock_request.expect(:run, failure_response)

      start_time = Time.now

      Typhoeus::Request.stub(:new, ->(*) { mock_request }) do
        client.get("/todos")
      end

      elapsed = Time.now - start_time

      assert elapsed > 3.9, "Expected ~4s total delay (2s + 2s), got #{elapsed.round(2)}s"
    end
  end

  private

  def stub_request(code: 200, return_code: :ok, body: {})
    Typhoeus.stub("https://api.test/todos").and_return(Typhoeus::Response.new(code:, return_code:, body:))
  end

  def failure_response(code = 503, body = {})
    Typhoeus::Response.new(code:, body:)
  end

  def success_response(code = 200, body = { success: true })
    Typhoeus::Response.new(code:, body:)
  end
end
