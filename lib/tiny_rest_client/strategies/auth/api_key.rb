# frozen_string_literal: true

module Strategies
  module Auth
    class ApiKey < Base
      attr_reader :token, :location, :name

      def initialize(credentials = {})
        @token = require!(credentials[:token], :token)
        @location = credentials.fetch(:in, :header).to_sym
        @name = credentials.fetch(:name) do
          location == :header ? "X-API-Key" : "api_key"
        end
      end

      def execute(request)
        case location
        when :header
          request.headers[name] = token
        when :query, :param
          request.params[name] = token
        else
          raise ArgumentError, "Invalid key: #{location}. Allowed keys: :header or :query."
        end
      end
    end
  end
end
