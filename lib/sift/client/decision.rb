require_relative "../router"

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
        "#{Router::API3_ENDPOINT}/v3/accounts/#{account_id}/decisions"
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
        user_id = configs.delete(:user_id)
        Router.post(apply_to_user_path(user_id), {
          body: configs.merge(decision_id: id)
        })
      end

      private

      def apply_to_user_path(user_id)
        "#{self.class.index_path(account_id)}/users/#{user_id}"
      end

      def apply_to_order_path(user_id, order_id)
        "#{apply_to_user_path(user_id)}/orders/#{order_id}"
      end
    end
  end
end

