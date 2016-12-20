require "cgi"

require_relative "../router"
require_relative "../validate/decision"
require_relative "../utils/hash_getter"
require_relative "./decision/apply_to"

module Sift
  class Client
    class Decision
      FILTER_PARAMS = %w{ limit entity_type abuse_types from }

      attr_reader :account_id, :api_key

      def initialize(api_key, account_id)
        @account_id = account_id
        @api_key = api_key
      end

      def list(options = {})
        getter = Utils::HashGetter.new(options)

        if path = getter.get(:next_ref)
          request_next_page(path)
        else
          Router.get(index_path, query: build_query(getter))
        end
      end

      def build_query(getter)
        FILTER_PARAMS.inject({ api_key: api_key }) do |result, filter|
          if value = getter.get(filter)
            result[filter] = value.is_a?(Array) ? value.join(",") : value
          end

          result
        end
      end

      def apply_to(configs = {})
        getter = Utils::HashGetter.new(configs)

        ApplyTo.new(getter.get(:decision_id), configs).run
      end

      def index_path
        "#{Router::API3_ENDPOINT}/v3/accounts/" +
          "#{CGI.escape(account_id)}/decisions"
      end

      private

      def request_next_page(path)
        Router.get(path, query: build_query(Utils::HashGetter.new({})))
      end
    end
  end
end

