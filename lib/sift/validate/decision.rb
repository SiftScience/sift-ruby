require_relative "primitive"

module Sift
  module Validate
    class Decision
      attr_reader :configs, :errors

      def initialize(configs = {})
        @configs = configs
      end

      def valid_user?
        clear_errors!
        validate_key_string_or_number(:user_id)
        errors.empty?
      end

      def valid_order?
        clear_errors!
        validate_key_string_or_number(:user_id, :order_id)
        errors.empty?
      end

      private

      def validate_primitive
        Validate::Primitive
      end

      def validate_key_string_or_number(*keys)
        keys.each do |key|
          if error_message = validate_primitive.string_or_number(configs[key])
            errors[key] << "#{key} #{error_message}"
          end
        end
      end

      def clear_errors!
        @errors = Hash.new { |h, k| h[k] = [] }
      end
    end
  end
end
