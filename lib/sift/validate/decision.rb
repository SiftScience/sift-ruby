require_relative "primitive"

module Sift
  module Validate
    class Decision
      attr_reader :configs, :error_messages

      def initialize(configs = {})
        @configs = configs
      end

      def valid_order?
        run do
          validate_key(:non_empty_string, :user_id, :order_id)
        end
      end

      def valid_user?
        run do
          validate_key(:non_empty_string, :user_id)
        end
      end

      private

      def run
        clear_errors!
        yield
        error_messages.empty?
      end

      def validate_primitive
        Validate::Primitive
      end

      def validate_key(type, *keys)
        keys.each do |key|
          if error_message = validate_primitive.public_send(type, get(key))
            error_messages << "#{key} #{error_message}"
          end
        end
      end

      def clear_errors!
        @error_messages = []
      end

      def get(key)
        configs[key] || configs[key.to_s]
      end
    end
  end
end
