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
            decision.append_api_key(decision.index_path)
          ).to_return(body: MultiJson.dump(FakeDecisions.index))

          response = decision.list

          expect(response.ok?).to be(true)
          expect(response.body["data"]).to contain_exactly(*FakeDecisions.index[:data])
        end

        it "with an unsuccessful response will return a response object" do
          stub_request(
            :get,
            decision.append_api_key(decision.index_path)
          ).to_return(status: 404, body: "{}")

          response = decision.list

          expect(response.ok?).to be(false)
          expect(response.http_status_code).to be(404)
        end
      end
    end
  end
end
