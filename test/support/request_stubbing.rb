# frozen_string_literal: true

module RequestStubbing
  def stub_request_with(method, endpoint:, expected_params: {}, expected_body: nil, &)
    mock_response = Minitest::Mock.new.expect(:run, { code: 200 })

    Request.stub(:new, lambda { |actual_method, _base_url, **opts|
      assert_equal method, actual_method, "Wrong HTTP method"
      assert_equal endpoint, opts[:endpoint], "Wrong endpoint"

      if expected_params.any?
        assert_equal expected_params, opts[:params] || {}, "Wrong params"
      else
        assert (opts[:params].nil? || opts[:params].empty?), "Unexpected params present"
      end

      if expected_body
        assert_equal expected_body, opts[:body], "Wrong body"
      else
        refute opts.key?(:body), "Body should not be present"
      end

      # Optional: add more assertions here later (headers, auth_config, etc.)
      mock_response
    }, &)

    mock_response.verify
  end
end
