# frozen_string_literal: true

module Strategies
  module Auth
    class Bearer < Base
      attr_reader :token

      def initialize(credentials = {})
        @token = require!(credentials[:token], :token)
      end

      def execute(request)
        request.headers["Authorization"] = "Bearer #{token}"
      end
    end
  end
end
