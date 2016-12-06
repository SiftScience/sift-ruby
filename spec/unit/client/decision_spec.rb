require_relative "../../spec_helper"
require "multi_json"

require "spec/fixtures/fake_responses"
require "sift/client/decision"
require "sift/router"

module Sift
  class Client
    describe Decision do
      let(:api_key) { "test_api_key" }
      let(:account_id) { "test_account_id" }
      let(:decision) { Decision.new(api_key, account_id) }

      describe "#list" do
        it "will return a response object that is ok" do
          stub_request(
            :get,
            "#{Decision.index_path(account_id)}?api_key=#{api_key}"
          ).to_return(body: MultiJson.dump(FakeDecisions.index))

          response = decision.list

          expect(response.ok?).to be(true)
          expect(response.body["data"]).to contain_exactly(*FakeDecisions.index[:data])
        end

        it "with an unsuccessful response will return a response object" do
          stub_request(
            :get,
            "#{Decision.index_path(account_id)}?api_key=#{api_key}"
          ).to_return(status: 404, body: "{}")

          response = decision.list

          expect(response.ok?).to be(false)
          expect(response.http_status_code).to be(404)
        end
      end

      describe "attributes" do
        list_of_attributes = %w{ id name description entity_type abuse_type
          category webhook_url created_at created_by updated_at updated_by }

        let(:attributes) {
          list_of_attributes.inject({}) do |result, name|
            result[name] = "decision_#{name}"
            result
          end
        }

        let(:decision) { Decision.new("id", "account", attributes) }

        list_of_attributes.each do |attribute|
          it "will return value of #{attribute}" do
            expect(decision.public_send(attribute))
              .to eq(attributes[attribute])
          end
        end
      end

      describe ".apply_to" do
        context "when successful" do
          it "will a hash with the response from server" do

          end
        end
      end

      describe ".apply_to!" do
        let (:decision) {
          Decision.new(api_key, account_id, { "id" => "block_user" })
        }

        it "will apply a decision to an user" do
          user_id = "bad_user"

          body = {
            source: "automated_rule",
            description: "This user is bad coz"
          }

          raw_response = {
            "time" => Time.now.to_i,
            "status" => 0,
            "error_message" => "OK"
          }

          path = decision.send(:apply_to_user_path, user_id)

          stub_request(:post, decision.send(:append_api_key, path))
            .with(body: MultiJson.dump(body.merge(decision_id: decision.id)))
            .to_return({
              body: MultiJson.dump(raw_response)
            })

          response = decision.apply_to!(body.merge({
            user_id: user_id,
          }))

          expect(response.body).to eq(raw_response)
        end

        context "invalid configs" do
          it "will throw an error with an invalid user_id" do
            expect { decision.apply_to! }.to raise_error(InvalidArgument)

            expect { decision.apply_to!(user_id: /asdfas/) }
              .to raise_error(InvalidArgument)

            expect { decision.apply_to!(user_id: 14) }
              .to raise_error(InvalidArgument)
          end

          it "will throw an error without an order_id" do
            error_message = "order_id " +
              "#{Validate::Primitive::ERROR_MESSAGES[:non_empty_string]}," +
              " got NilClass"

            expect { decision.apply_to!(user_id: "asdfasdf", order_id: nil) }
              .to raise_error(InvalidArgument)

            begin
              decision.apply_to!(user_id: "asdfasdf", order_id: nil)
            rescue InvalidArgument => e
              expect(e.message).to eq(error_message)
            end
          end
        end
      end
    end
  end
end
