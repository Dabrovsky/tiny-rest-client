# frozen_string_literal: true

# The Response class represents a response object that
# can be used to represent success or failure outcomes
class Response
  attr_reader :code, :status, :body, :headers

  def initialize(code: nil, status: nil, body: nil, headers: nil)
    @code = code
    @status = status
    @headers = headers
    @body = parse_body(body)
  end

  def success?
    code.to_i.between?(200, 299)
  end

  def failure?
    !success?
  end

  def parse_body(raw_body)
    return raw_body unless raw_body.is_a?(String)

    begin
      JSON.parse(raw_body, symbolize_names: true)
    rescue JSON::ParserError
      raw_body
    end
  end
end
