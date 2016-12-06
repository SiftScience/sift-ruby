require_relative "./version"
require_relative "./client"
require_relative "./errors"

module Sift
  class Router
    include HTTParty

    API_ENDPOINT = 'https://api.siftscience.com'
    API3_ENDPOINT = 'https://api3.siftscience.com'

    class << self
      def get(path, options = {})
        serialize_body(options)
        handle_response(super(path, options))
      end

      def post(path, options = {})
        serialize_body(options)
        handle_response(super(path, options))
      end

      def serialize_body(options)
        options[:body] = MultiJson.dump(options[:body]) if options[:body]
      end

      def handle_response(response)
        if (200..299).cover?(response.code)
          Response.new(
            response.body,
            response.code,
            response.response
          )
        else
          raise ApiError.new("Response came back with a non 200", response)
        end
      end
    end

  end
end
