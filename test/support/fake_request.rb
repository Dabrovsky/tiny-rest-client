# frozen_string_literal: true

class FakeRequest
  attr_accessor :headers, :params, :rest

  def initialize
    @headers = {}
    @params = {}
    @rest = {}
  end
end
