module Sift
  module Validate
    class Primitive
      ERROR_MESSAGES = {
        non_empty_string: "must be a non-empty string",
        numeric: "must be a number",
        string_or_number: "must be a string or a number",
      }

      class << self
        def non_empty_string(value)
          if !value.is_a?(String)
            "#{ERROR_MESSAGES[:non_empty_string]}, got #{value.class}"
          elsif value.empty?
            empty_string_message(:non_empty_string)
          end
        end

        def numeric(value)
          if !value.is_a?(Numeric)
            ERROR_MESSAGES[:numeric]
          end
        end

        def string_or_number(value)
          if (value.is_a?(String) && value.empty?)
            return empty_string_message(:string_or_number)
          end

          if value.nil? || !(value.is_a?(String) || value.is_a?(Numeric))
            "#{ERROR_MESSAGES[:string_or_number]}, got #{value.class}"
          end
        end

        private

        def empty_string_message(message)
          "#{ERROR_MESSAGES[message]}, got an empty string"
        end
      end
    end
  end
end
