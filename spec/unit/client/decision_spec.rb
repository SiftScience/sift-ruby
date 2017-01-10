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
        # TODO(Kaoru): When we move to webmock 2 we won't need to do this
        # hackery
        #
        # https://github.com/bblimke/webmock/blob/master/CHANGELOG.md#200
        #
        protocal, uri = decision.index_path.split(/(?<=https\:\/\/)/)

        protocal + api_key + "@" + uri
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
            entity_type: "user",
            limit: 10
          }.inject("?")  do |result, (key, value)|
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

        it "with an unsuccessful response will return a response object" do
          stub_request(:get, decision_index_path)
            .to_return(status: 404, body: "{}")

          response = decision.list

          expect(response.ok?).to be(false)
          expect(response.http_status_code).to be(404)
        end

        it "will fetch next page" do
          next_page = "#{decision.index_path}?from=100"

          stub_request(:get, "#{decision_index_path}?from=100")
            .to_return(body: MultiJson.dump(FakeDecisions.index))

          response = decision.list({ "next_ref" => next_page })

          expect(response.ok?).to be(true)
        end
      end
    end
  end
end
