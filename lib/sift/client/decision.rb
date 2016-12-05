require "sift/router"

module Sift
  class Client
    class Decision
      DECISION_ATTRIBUTES = %w{ id name }
      def self.index(api_key, account_id, options = {})
        response = Router.decisions_index(api_key, account_id, options)

        response.body["data"].map do |raw_decision|
          new(api_key, account_id, raw_decision)
        end
      end

      attr_reader :account_id, :api_key

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

      # should have a bang method which raises and error instead of returning
      # false
      def apply_to(configs = {})
        if configs.has_key?(:order_id)
          apply_to_order(configs)
        else
          apply_to_user(configs)
        end
      end

      def apply_to_order(configs)
      end

      def apply_to_user(configs)
      end
    end
  end
end

