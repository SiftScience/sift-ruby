require "cgi"

require_relative "../router"
require_relative "../validate/decision"
require_relative "./decision/apply_to"

module Sift
  class Client
    class Decision
      attr_reader :account_id, :api_key, :raw

      def initialize(api_key, account_id, raw = {})
        @raw = raw
        @account_id = account_id
        @api_key = api_key
      end

      def list
        path = append_api_key(index_path)
        Router.get(path)
      end

      def apply_to(decision_id, configs)
        ApplyTo.new(decision_id, configs).run
      end

      def index_path
        "#{Router::API3_ENDPOINT}/v3/accounts/" +
          "#{CGI.escape(account_id)}/decisions"
      end

      def append_api_key(path)
         "#{path}?api_key=#{api_key}"
      end
    end
  end
end

