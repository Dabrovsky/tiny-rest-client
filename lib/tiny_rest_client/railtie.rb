# frozen_string_literal: true

require "rails"
require "rails/generators"

module TinyRestClient
  class Railtie < ::Rails::Railtie
    initializer "tiny_rest_client.load_generators" do
      require "generators/tiny_rest_client/client_generator"
    end
  end
end
