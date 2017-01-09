require_relative "../../../spec_helper"

require "sift/client/decision/apply_to"

module Sift
  class Client
    class Decision
      describe ApplyTo do
        let(:decision_id) { "block_it" }
        let(:api_key) { "customer_key" }
        let(:decision) { Decision.new(api_key, "account_id") }

        describe "attributes" do
          ApplyTo::PROPERTIES.each do |attribute|
            it "can read #{attribute} whether it is a symbol or string" do
              expected_value = "right_#{attribute}#{Time.now.to_i}"
              string_hash = {}
              string_hash[attribute] = expected_value

              applier = ApplyTo.new(api_key, "id", string_hash)
              expect(applier.public_send(attribute)).to(
                eq(expected_value),
                "#{attribute} did not read the right string value"
              )

              symbol_hash = {}
              symbol_hash[attribute.to_sym] = expected_value

              applier = ApplyTo.new(api_key, "id", symbol_hash)
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

            applier = ApplyTo.new(api_key, decision_id, configs)
            request_body = MultiJson.dump(applier.send(:request_body))

            response_body = {
              "entity" => {
                "id" => "USER_ID",
                "type" => "user"
              },
              "decision" => {
                "id" => decision_id
              },
              "time" => Time.now.to_i
            }

            stub_request(:post, put_auth_in_url(api_key, applier.send(:path)))
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

              applier = ApplyTo.new(api_key, decision_id, configs)

              response = applier.run
              non_empty_string_error =
                Validate::Primitive::ERROR_MESSAGES[:non_empty_string]
              error_message = "order_id #{non_empty_string_error}, got NilClass"

              expect(response.ok?).to be(false)
              expect(response.body["error_message"]).to eq(error_message)

              ## Invalid user_id

              configs.delete(:user_id)
              configs.delete("order_id")

              applier = ApplyTo.new(api_key, decision_id, configs)

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

              applier = ApplyTo.new(api_key, decision_id, configs)
              request_body = MultiJson.dump(applier.send(:request_body))

              response_body = {
                "error" => "not_found",
                "description" => "No decision with id non_existent_decision_id"
              }

              stub_request(:post, put_auth_in_url(api_key, applier.send(:path)))
                .with(body: request_body)
                .to_return(body: MultiJson.dump(response_body), status: 404)

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

            applier = ApplyTo.new(api_key, decision_id, {
              user_id: user_id,
              account_id: decision.account_id,
            })

            path = Client::API3_ENDPOINT +
              "/v3/accounts/#{decision.account_id}" +
              "/users/#{CGI.escape(user_id)}" +
              "/decisions"


            expect(applier.send(:path)).to eq(path)

            applier = ApplyTo.new(api_key, decision_id, {
              user_id: user_id,
              account_id: decision.account_id,
              order_id: order_id
            })

            path = Client::API3_ENDPOINT +
              "/v3/accounts/#{decision.account_id}/users/" +
              "#{CGI.escape(user_id)}/orders/#{CGI.escape(order_id)}" +
              "/decisions"

            expect(applier.send(:path)).to eq(path)
          end
        end

        # TODO(Kaoru): When we move to webmock 2 we won't need to do this
        # hackery
        #
        # https://github.com/bblimke/webmock/blob/master/CHANGELOG.md#200
        #
        def put_auth_in_url(api_key, url)
          protocal, uri = url.split(/(?<=https\:\/\/)/)

          protocal + api_key + "@" + uri
        end
      end
    end
  end
end
