require "multi_json"

require_relative "../../validate/primitive"
require_relative "../../client"
require_relative "../../router"

module Sift
  class Client
    class Decision
      class ApplyTo
        PROPERTIES = %w{ source analyst description order_id user_id decision }

        attr_reader :decision_id, :configs, :getter

        PROPERTIES.each do |attribute|
          class_eval %{
            def #{attribute}
              getter.get(:#{attribute})
            end
          }
        end

        def initialize(decision_id, configs)
          @decision_id = decision_id
          @configs = configs
          @getter = Utils::HashGetter.new(configs)
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
          Router.post(path, {
            body: request_body,
            query: query_param
          })
        end

        def request_body
          {
            source: source,
            description: description,
            analyst: analyst,
            decision_id: decision_id
          }
        end

        def query_param
          { api_key: decision.api_key }
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
          if applying_to_order?
            "#{user_path}/orders/#{CGI.escape(order_id)}"
          else
            user_path
          end
        end

        def user_path
          "#{decision.index_path}/users/#{CGI.escape(user_id)}"
        end
      end
    end
  end
end
