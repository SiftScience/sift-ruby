require "multi_json"

require_relative "../../validate/primitive"
require_relative "../../client"
require_relative "../../router"

module Sift
  class Client
    class Decision
      class ApplyTo
        PROPERTIES = %w{ source analyst description order_id user_id decision }

        attr_reader :decision_id, :configs

        PROPERTIES.each do |attribute|
          class_eval %{
            def #{attribute}
              configs["#{attribute}"] || configs[:#{attribute}]
            end
          }
        end

        def initialize(decision_id, configs)
          @decision_id = decision_id
          @configs = configs
        end

        def run
          if errors.empty?
            send_request
          else
            Response.new(
              MultiJson.dump(
                status: 55,
                error_message: errors.join(", ")
              ),
              400,
              nil
            )
          end
        end

        private

        def send_request
          Router.post(path, { body: request_body })
        end

        def request_body
          {
            source: source,
            description: description,
            analyst: analyst,
            decision_id: decision_id
          }
        end

        def errors
          validator = Validate::Decision.new(configs)

          if applying_to_order?
            validator.valid_order?
          else
            validator.valid_user?
          end

          validator.error_messages
        end

        def applying_to_order?
          configs.has_key?("order_id") || configs.has_key?(:order_id)
        end

        def path
          path = if applying_to_order?
            "#{user_path}/orders/#{CGI.escape(order_id)}"
          else
            user_path
          end

          append_api_key(path)
        end

        def user_path
          "#{decision.index_path}/users/#{CGI.escape(user_id)}"
        end

        def append_api_key(path)
          decision.append_api_key(path)
        end
      end
    end
  end
end
