# frozen_string_literal: true

module Strategies
  module Auth
    class BasicAuth < Base
      attr_reader :user, :pass

      def initialize(credentials = {})
        @user = require!(credentials[:user], :user)
        @pass = require!(credentials[:password], :password)
      end

      def execute(request)
        request.rest[:userpwd] = "#{user}:#{pass}"
      end
    end
  end
end
