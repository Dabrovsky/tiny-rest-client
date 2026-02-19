# frozen_string_literal: true

require "typhoeus"
require "json"

require "tiny_rest_client/strategies/auth/base"
require "tiny_rest_client/strategies/auth/basic_auth"
require "tiny_rest_client/strategies/auth/bearer"
require "tiny_rest_client/strategies/auth/api_key"
require "tiny_rest_client/strategies/auth/registry"
require "tiny_rest_client/request"
require "tiny_rest_client/response"
require "tiny_rest_client/version"

module TinyRestClient
  class Core
    class << self
      def api_path(value = nil)
        @api_path ||= value
      end

      def authorization(type = nil, **credentials)
        if type
          @auth_config = {
            type.to_sym => { credentials: }
          }
        else
          @auth_config
        end
      end

      def header(name, value)
        @headers ||= {}
        @headers[name] = value
        @headers
      end

      def headers(hash = nil)
        if hash
          @headers = (@headers || {}).merge(hash.transform_keys(&:to_s))
        else
          @headers || {}
        end
      end
    end

    attr_reader :api_path, :auth_config, :headers

    def initialize(api_path: nil, auth: nil, headers: {})
      @api_path = api_path || self.class.api_path || raise(ArgumentError, "Undefined api_path base URL")
      @auth_config = auth || self.class.authorization
      @headers = merge_headers(headers)
    end

    def head(endpoint, params = {})
      Request.new(:head, api_path, endpoint:, params:, **common_params).run
    end

    def get(endpoint, params = {})
      Request.new(:get, api_path, endpoint:, params:, **common_params).run
    end

    def post(endpoint, body = {})
      Request.new(:post, api_path, endpoint:, body:, **common_params).run
    end

    def patch(endpoint, body = {})
      Request.new(:patch, api_path, endpoint:, body:, **common_params).run
    end

    def put(endpoint, body = {})
      Request.new(:put, api_path, endpoint:, body:, **common_params).run
    end

    def delete(endpoint, params = {})
      Request.new(:delete, api_path, endpoint:, params:, **common_params).run
    end

    def options(endpoint, params = {})
      Request.new(:options, api_path, endpoint:, params:, **common_params).run
    end

    private

    def merge_headers(instance_headers)
      (self.class.headers || {}).merge(instance_headers || {}).transform_keys(&:to_s)
    end

    def common_params
      { headers:, auth_config: }
    end
  end
end
