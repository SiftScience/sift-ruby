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
      let(:decision_index_path) {
        "#{decision.index_path}?api_key=#{decision.api_key}"
      }

      describe "#list" do
        it "will return a response object that is ok" do
          stub_request(:get, decision_index_path)
            .to_return(body: MultiJson.dump(FakeDecisions.index))

          response = decision.list

          expect(response.ok?).to be(true)
          expect(response.body["data"])
            .to contain_exactly(*FakeDecisions.index[:data])
        end

        it "will pass on query params" do
          query_param = {
            abuse_types: %w{promo_abuse content_abuse},
            limit: 10,
            entity_type: "user"
          }.inject("")  do |result, (key, value)|
            value = value.join(",") if value.is_a? Array
            "#{result}&#{key}=#{CGI.escape(value.to_s)}"
          end

          stub_request(:get, "#{decision_index_path}#{query_param}")
            .to_return(body: MultiJson.dump(FakeDecisions.index))

          response = decision.list({
            limit: 10,
            entity_type: "user",
            abuse_types: %w{promo_abuse content_abuse}
          })

          expect(response.ok?).to be(true)
        end

        it "will ignore query params if passed in" do
          index_path = "#{decision.index_path}?limit=10"
          stub_request(:get, "#{index_path}&api_key=#{api_key}")
            .to_return(body: MultiJson.dump(FakeDecisions.index))

          response = decision.list({
            limit: 10,
            entity_type: "user",
            abuse_types: %w{promo_abuse content_abuse},
            next_ref: index_path
          })

          expect(response.ok?).to be(true)
        end

        it "with an unsuccessful response will return a response object" do
          stub_request(:get, decision_index_path)
            .to_return(status: 404, body: "{}")

          response = decision.list

          expect(response.ok?).to be(false)
          expect(response.http_status_code).to be(404)
        end
      end
    end
  end
end
