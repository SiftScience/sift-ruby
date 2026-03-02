require_relative "./version"
require_relative "./client"

module Sift
  class Router < Client

    class << self
      def get(path, options = {})
        client_class = options.delete(:client_class) || Sift::Client
        options[:base_uri] = nil
        serialize_body(options)
        add_default_headers(options)
        wrap_response(client_class.api3_client.get(path, options))
      end

      def post(path, options = {})
        client_class = options.delete(:client_class) || Sift::Client
        options[:base_uri] = nil
        serialize_body(options)
        add_default_headers(options)
        wrap_response(client_class.api3_client.post(path, options))
      end

      def serialize_body(options)
        options[:body] = MultiJson.dump(options[:body]) if options[:body]
      end

      def add_default_headers(options)
        options[:headers] = {
          "User-Agent" => Sift::Client.user_agent
        }.merge(options[:headers] || {})
      end

      def wrap_response(response)
        Response.new(
          response.body,
          response.code,
          response.response
        )
      end
    end

  end
end
