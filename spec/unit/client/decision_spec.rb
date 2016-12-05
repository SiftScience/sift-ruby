require_relative "../../spec_helper"
require "multi_json"
require "spec/fixtures/fake_responses"
require "sift/client/decision"

module Sift
  class Client
    describe Sift::Client::Decision do
      describe "#index" do
        it "will return a list of the customer's decisions" do
          stub_request(
            :get,
            "https://api3.siftscience.com/v3/customers/1234/decisions"
          ).to_return(:body => MultiJson.dump(FakeDecisions.index))

          result = Decision.index("1234")

          expect(result.map(&:id)).to match_array(
            FakeDecisions.index[:data].map { |raw_decision| raw_decision[:id] }
          )
        end
      end
    end
  end
end
