# frozen_string_literal: true

module TinyRestClient
  module Generators
    class ClientGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      argument :name, type: :string, required: true, banner: "NAME"
      argument :api_path, type: :string, required: false, default: "your_api_path", banner: "URL"

      class_option :namespace, type: :string, default: "clients", desc: "Namespace (default clients)"

      desc "Generates a TinyRestClient subclass"

      def create_client_file
        client_path = "app/#{namespace.downcase}/#{name.downcase}_client.rb"
        template "client.rb.tt", client_path
      end

      def create_test_files
        return if options[:skip_tests]

        framework = options[:test_framework] || detect_test_framework

        case framework
        when "rspec"
          client_test_path = "spec/#{namespace.downcase}/#{name.downcase}_client_spec.rb"
          template "client_spec.rb.tt", client_test_path
        when "minitest"
          client_test_path = "test/#{namespace.downcase}/#{name.downcase}_client_test.rb"
          template "client_test.rb.tt", client_test_path
        else
          say "Unknown test framework: #{framework}", :yellow
        end
      end

      private

      def detect_test_framework
        if defined?(RSpec) || File.exist?(File.join(destination_root, "spec"))
          "rspec"
        else
          "minitest"
        end
      end

      def module_names
        name.split("/").map(&:capitalize).join("::")
      end

      def class_name
        "#{module_names}Client"
      end

      def namespace
        options[:namespace].split("/").first
      end
    end
  end
end
