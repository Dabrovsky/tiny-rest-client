# frozen_string_literal: true

module Strategies
  module Auth
    class Base
      def execute
        raise NotImplementedError
      end

      private

      def require!(value, name)
        value || raise(ArgumentError, "Missing #{name} parameter")
      end
    end
  end
end
