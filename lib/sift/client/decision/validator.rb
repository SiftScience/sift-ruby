require "sift/errors"

module Sift
  class Client
    class Decision
      class Validator
        attr_reader :configs, :errors, :raise_error

        def initialize(configs = {})
          @configs = configs
          @errors = Hash.new { |h, k| h[k] = [] }
        end

        def valid_order_configs?
          validate_non_empty_string(:order_id)
          validate_user_configs
        end

        def validate_user_configs
          validate_non_empty_string!(:user_id)
        end

        private

        def raise_error?
          raise_error == true
        end

        def validate_non_empty_string(key_name)
          !configs[key_name].nil? &&
              configs[key_name].is_a?(String) &&
              !configs[key_name].empty?
        end

        def validate_non_nil(key_name)
          if configs[key_name].nil?
            errors[key_name] << "#{key_name} must be a non nil value"
          end
        end

        def validate_is_string_or_number(key_name)
          unless configs[key_name].is_a?(String) ||
              configs[key_name].is_a?(Numeric)
            errors[key_name] << "#{key_name} must be a string or number"
          end
        end
      end
    end
  end
end
