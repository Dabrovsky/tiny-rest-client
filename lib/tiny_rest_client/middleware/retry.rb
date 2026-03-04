# frozen_string_literal: true

module Middleware
  module Retry
    DEFAULT_OPTIONS = {
      count: 0,                   # 0 = no retries by default
      on: [500, 502, 503, 504],   # only these server errors by default
      delay: 1.0                  # 1 second between retries by default
    }.freeze

    def self.call(request, options = {})
      opts = DEFAULT_OPTIONS.merge(options)
      attempt = 0

      loop do
        attempt += 1

        begin
          response = request.run
          return response if response.success?

          if attempt <= opts[:count] && opts[:on].include?(response.code)
            sleep opts[:delay].to_f
            next
          end

          return response
        rescue Typhoeus::Errors::TyphoeusError => e
          if attempt <= opts[:count]
            sleep opts[:delay].to_f
            retry
          end

          raise Typhoeus::Errors::TyphoeusError, e
        end
      end
    end
  end
end
