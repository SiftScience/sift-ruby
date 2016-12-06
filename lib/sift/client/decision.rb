require "cgi"

require_relative "../router"
require_relative "../validate/decision"

module Sift
  class Client
    class Decision
      DECISION_ATTRIBUTES = %w{
        id
        name
        description
        entity_type
        abuse_type
        category
        webhook_url
        created_at
        created_by
        updated_at
        updated_by
      }

      def self.list(api_key, account_id, options = {})
        path = "#{index_path(account_id)}?api_key=#{api_key}"
        response = Router.get(path)

        response.body["data"].map do |raw_decision|
          new(api_key, account_id, raw_decision)
        end
      end

      def self.index_path(account_id)
        "#{Router::API3_ENDPOINT}/v3/accounts/" +
          "#{url_escape(account_id)}/decisions"
      end

      attr_reader :account_id, :api_key, :raw

      def initialize(api_key, account_id, raw = {})
        @raw = raw
        @account_id = account_id
        @api_key = api_key
      end

      DECISION_ATTRIBUTES.each do |attribute|
        class_eval %{
          def #{attribute}
            raw["#{attribute}"]
          end
        }
      end

      def apply_to(configs = {})
        if configs.has_key?(:order_id)
          validate!(:order, configs)
          apply_to_order(configs)
        else
          validate!(:user, configs)
          apply_to_user(configs)
        end
      end

      private

      def apply_to_user_path(user_id)
        "#{self.class.index_path(account_id)}/users/#{url_escape(user_id)}"
      end

      def apply_to_order_path(user_id, order_id)
        "#{apply_to_user_path(user_id)}/orders/#{url_escape(order_id)}"
      end

      def apply_to_user(configs)
        user_id = configs.delete(:user_id)
        path = append_api_key(apply_to_user_path(user_id))

        handle_response Router.post(path, {
          body: configs.merge(decision_id: id)
        })
      end

      def apply_to_order(configs)
        user_id = configs.delete(:user_id)
        order_id = configs.delete(:order_id)
        path = append_api_key(apply_to_order(user_id, order_id))

        handle_response Router.post(path, {
          body: configs.merge(decision_id: id)
        })
      end

      def handle_response(response)
        if response.body["status"] != 0
          raise InvalidArgument, response.body["error_message"]
        end

        response
      end

      def validate!(type, configs)
        validator = Validate::Decision.new(configs)

        unless validator.public_send("valid_#{type}?")
          raise InvalidArgument, validator.error_messages.join(", ")
        end
      end

      def url_escape(value)
        CGI.escape(value)
      end

      def append_api_key(path)
        "#{path}?api_key=#{api_key}"
      end
    end
  end
end

