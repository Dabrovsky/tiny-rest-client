# frozen_string_literal: true

module Strategies
  module Auth
    module Registry
      STRATEGIES = {
        bearer: Bearer,
        api_key: ApiKey,
        basic_auth: BasicAuth
      }.freeze

      module_function

      def fetch(type)
        STRATEGIES.fetch(type) do
          raise ArgumentError, "Unsupported auth type: #{type}"
        end
      end
    end
  end
end
