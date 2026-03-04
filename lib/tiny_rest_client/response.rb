# frozen_string_literal: true

# The Response class represents a response object that
# can be used to represent success or failure outcomes
class Response
  attr_reader :code, :status, :body, :headers, :timed_out

  def initialize(code: nil, status: nil, body: nil, headers: nil, timed_out: false)
    @code = code&.to_i
    @status = status
    @headers = headers
    @body = parse_body(body)
    @timed_out = timed_out
  end

  def success?
    code.between?(200, 299)
  end

  def failure?
    !success?
  end

  def timed_out?
    timed_out
  end

  private

  def parse_body(raw_body)
    return raw_body unless raw_body.is_a?(String)

    begin
      JSON.parse(raw_body, symbolize_names: true)
    rescue JSON::ParserError
      raw_body
    end
  end
end
