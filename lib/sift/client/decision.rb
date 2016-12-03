require "sift/router"

module Sift
  class Client
    class Decision
      attr_reader :api_key, :account_id, :raw

      DECISION_ATTRIBUTES = %w{ id name }

      def self.index(api_key, account_id, options = {})
        response = Router.decisions_index(api_key, account_id, options)

        response.body["data"].map do |raw_decision|
          new(raw_decision)
        end
      end

      def initialize(raw = {})
        @raw = raw
      end

      DECISION_ATTRIBUTES.each do |attribute|
        class_eval %{
          def #{attribute}
            raw["#{attribute}"]
          end
        }
      end
    end
  end
end

