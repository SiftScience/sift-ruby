require "sift/version"
require "sift/client"
require "sift/errors"

module Sift
  class Router
    include HTTParty

    API_ENDPOINT = 'https://api.siftscience.com'
    API3_ENDPOINT = 'https://api3.siftscience.com'

    class << self
      def decisions_index(api_key, account_id, options = {})
        path = "#{API3_ENDPOINT}/v3/customers/#{account_id}/decisions"
        handle_response(get(path, options))
      end

      def handle_response(response)
        if (200..299).cover?(response.code)
          Response.new(
            raw_response.body,
            raw_response.code,
            raw_response.response
          )
        else
          raise ApiError.new("Response came back with a non 200", response)
        end
      end
    end

  end
end
