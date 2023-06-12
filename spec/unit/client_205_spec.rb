require_relative "../spec_helper"
require "sift"

describe Sift::Client do

  before :each do
    Sift.api_key = nil
  end
  
  def valid_transaction_properties
    {
      :$buyer_user_id => "123456",
      :$seller_user_id => "654321",
      :$amount => 1253200,
      :$currency_code => "USD",
      :$time => Time.now.to_i,
      :$transaction_id => "my_transaction_id",
      :$billing_name => "Mike Snow",
      :$billing_bin => "411111",
      :$billing_last4 => "1111",
      :$billing_address1 => "123 Main St.",
      :$billing_city => "San Francisco",
      :$billing_region => "CA",
      :$billing_country => "US",
      :$billing_zip => "94131",
      :$user_email => "mike@example.com"
    }
  end

  it "Successfully submits a v205 event with SCORE_PERCENTILES" do
    response_json = { :status => 0, :error_message => "OK"}
    stub_request(:post, "https://api.siftscience.com/v205/events?fields=SCORE_PERCENTILES").
      with { | request|
        parsed_body = JSON.parse(request.body)
        expect(parsed_body).to include("$buyer_user_id" => "123456")
        expect(parsed_body).to include("$api_key" => "overridden")
      }.to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    response = Sift::Client.new(:api_key => api_key, :version => "205")
               .track(event, properties, :api_key => "overridden",:include_score_percentile =>"true")
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end
end