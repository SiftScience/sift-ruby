require_relative "./version"
require_relative "./client"

module Sift
  class Router
    include HTTParty

    API_ENDPOINT = 'https://api.siftscience.com'
    API3_ENDPOINT = 'https://api3.siftscience.com'

    class << self
      def get(path, options = {})
        serialize_body(options)
        wrap_response(super(path, options))
      end

      def post(path, options = {})
        serialize_body(options)
        wrap_response(super(path, options))
      end

      def serialize_body(options)
        options[:body] = MultiJson.dump(options[:body]) if options[:body]
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
