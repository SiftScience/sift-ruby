require "sift/version"
require "sift/client"
require "sift/errors"

module Sift
  class Router
    include HTTParty

    API_ENDPOINT = 'https://api.siftscience.com'
    API3_ENDPOINT = 'https://api3.siftscience.com'

    class << self
      def decisions_index(account_id, options = {})
        path = decisions_path(account_id)
        handle_response(get(path, options))
      end

      def apply_decision_to_order(api_key, account_id, options = {})
        path = "#{API3_ENDPOINT}/v3/customers/#{account_id}/decisions"
        options[:query] ||= {}
        options[:query][:api_key] = api_key
        post(path, options)
      end

      def decisions_path(account_id)
        "#{API3_ENDPOINT}/v3/customers/#{account_id}/decisions"
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
