# frozen_string_literal: true

class Request
  attr_reader :method, :api_path, :headers, :body, :params, :endpoint, :retries, :rest

  def initialize(method, api_path, endpoint: "", headers: nil, auth_config: nil, body: nil, params: nil, retries: nil)
    @method = method || :get
    @api_path = api_path || raise(ArgumentError, "Define api_path base URL")
    @endpoint = endpoint
    @headers = headers
    @body = body
    @params = params
    @retries = retries
    @rest = {}

    configure_auth(auth_config)
  end

  def run
    Response.new(
      code: response.code,
      status: response.return_code,
      body: response.body,
      headers: response.headers,
      timed_out: response.timed_out?
    )
  rescue Typhoeus::Errors::TyphoeusError => e
    Response.new(
      code: 0,
      status: :internal_error,
      body: e.message.capitalize,
      headers: {}
    )
  end

  private

  def configure_auth(auth_config)
    return unless auth_config

    type, config = auth_config.first
    strategy = Strategies::Auth::Registry.fetch(type)
    strategy.new(**config[:credentials]).execute(self)
  end

  def request
    @request = Typhoeus::Request.new(
      [api_path, endpoint].join, method:, body:, params:, headers:, **rest
    )
  end

  def response
    @response ||= Middleware::Retry.call(request, retries)
  end
end
