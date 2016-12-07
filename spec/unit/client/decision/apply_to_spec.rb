require_relative "../../../spec_helper"

require "sift/client/decision/apply_to"

module Sift
  class Client
    class Decision
      describe ApplyTo do
        let(:decision_id) { "block_it" }
        let(:decision) { Decision.new("api_key", "account_id") }

        describe "attributes" do
          ApplyTo::PROPERTIES.each do |attribute|
            it "can read #{attribute} whether it is a symbol or string" do
              expected_value = "right_#{attribute}#{Time.now.to_i}"
              string_hash = {}
              string_hash[attribute] = expected_value

              applier = ApplyTo.new("id", string_hash)
              expect(applier.public_send(attribute)).to(
                eq(expected_value),
                "#{attribute} did not read the right string value"
              )

              symbol_hash = {}
              symbol_hash[attribute.to_sym] = expected_value

              applier = ApplyTo.new("id", symbol_hash)
              expect(applier.public_send(attribute)).to(
                eq(expected_value),
                "#{attribute} did not read the right symbol value"
              )
            end
          end
        end

        describe "#run" do
          it "will send a request to block user" do
            configs = {
              source: "manual",
              analyst: "foobar@example.com",
              description: "be blocking errrday allday",
              decision: decision,
              user_id: "user_1234"
            }

            applier = ApplyTo.new(decision_id, configs)
            request_body = MultiJson.dump(applier.send(:request_body))

            response_body = {
              "time" => Time.now.to_i,
              "status" => 0,
              "error_message" => "OK"
            }

            stub_request(:post, applier.send(:path))
              .with(body: request_body)
              .to_return(body: MultiJson.dump(response_body))

            response = applier.run

            expect(response.ok?).to be(true)
            expect(response.body).to eq(response_body)
          end

          context "without a valid user_id or order_id" do
            it "will return a response object with the error message" do
              configs = {
                source: "manual",
                analyst: "foobar@example.com",
                description: "be blocking errrday allday",
                decision: decision,
                user_id: "user_1234",
                "order_id" => nil
              }

              applier = ApplyTo.new(decision_id, configs)

              response = applier.run
              non_empty_string_error =
                Validate::Primitive::ERROR_MESSAGES[:non_empty_string]
              error_message = "order_id #{non_empty_string_error}, got NilClass"

              expect(response.ok?).to be(false)
              expect(response.body["error_message"]).to eq(error_message)

              ## Invalid user_id

              configs.delete(:user_id)
              configs.delete("order_id")

              applier = ApplyTo.new(decision_id, configs)

              response = applier.run
              error_message = "user_id #{non_empty_string_error}, got NilClass"

              expect(response.ok?).to be(false)
              expect(response.body["error_message"]).to eq(error_message)
            end
          end

          context "when api returns an error code" do
            it "will return a response with the information" do
              configs = {
                source: "manual",
                description: "be blocking errrday allday",
                decision: decision,
                user_id: "user_1234"
              }

              applier = ApplyTo.new(decision_id, configs)
              request_body = MultiJson.dump(applier.send(:request_body))

              response_body = {
                "time" => Time.now.to_i,
                "status" => 100,
                "error_message" => "Required field(s) not specified: analyst"
              }

              stub_request(:post, applier.send(:path))
                .with(body: request_body)
                .to_return(body: MultiJson.dump(response_body))

              response = applier.run

              expect(response.ok?).to be(false)
              expect(response.body).to eq(response_body)
            end
          end
        end

        describe "private#path" do
          it "will construct the right path given the configs" do
            user_id = "bad_user@example.com"
            order_id = "ORDER_1235"

            applier = ApplyTo.new(decision_id, {
              user_id: user_id,
              decision: decision
            })

            path = Router::API3_ENDPOINT +
              "/v3/accounts/#{decision.account_id}/decisions/users/" +
              "#{CGI.escape(user_id)}?api_key=#{decision.api_key}"

            expect(applier.send(:path)).to eq(path)

            applier = ApplyTo.new(decision_id, {
              user_id: user_id,
              decision: decision,
              order_id: order_id
            })

            path = Router::API3_ENDPOINT +
              "/v3/accounts/#{decision.account_id}/decisions/users/" +
              "#{CGI.escape(user_id)}/orders/#{CGI.escape(order_id)}" +
              "?api_key=#{decision.api_key}"

            expect(applier.send(:path)).to eq(path)
          end
        end

      end
    end
  end
end
