require "multi_json"

require_relative "../../validate/decision"
require_relative "../../client"
require_relative "../../router"
require_relative "../../utils/hash_getter"

module Sift
  class Client
    class Decision
      class ApplyTo
        PROPERTIES = %w{ source analyst description order_id user_id account_id }

        attr_reader :decision_id, :configs, :getter, :api_key

        PROPERTIES.each do |attribute|
          class_eval %{
            def #{attribute}
              getter.get(:#{attribute})
            end
          }
        end

        def initialize(api_key, decision_id, configs)
          @api_key = api_key
          @decision_id = decision_id
          @configs = configs
          @getter = Utils::HashGetter.new(configs)
        end

        def run
          if errors.empty?
            send_request
          else
            Response.new(
              MultiJson.dump({
                status: 55,
                error_message: errors.join(", ")
              }),
              400,
              nil
            )
          end
        end

        private

        def send_request
          Router.post(path, {
            body: request_body,
            headers: headers
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
            "#{user_path}/orders/#{CGI.escape(order_id)}/decisions"
          else
            "#{user_path}/decisions"
          end
        end

        def user_path
          "#{base_path}/users/#{CGI.escape(user_id)}"
        end

        def base_path
          "#{Client::API3_ENDPOINT}/v3/accounts/#{account_id}"
        end

        def headers
          {
            "Content-type" => "application/json"
          }.merge(Client.build_auth_header(api_key))
        end
      end
    end
  end
end
