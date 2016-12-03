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

  def score_response_json
    {
      :user_id => "247019",
      :score => 0.93,
      :reasons => [{
                     :name => "UsersPerDevice",
                     :value => 4,
                     :details => {
                     :users => "a, b, c, d"
                     }
                   }],
      :status => 0,
      :error_message => "OK"
    }
  end

  def action_response_json
    {
      :user_id => "247019",
      :score => 0.93,
      :actions => [{
                    :action_id => "1234567890abcdefghijklmn",
                    :time => 1437421587052,
                    :triggers => [{
                      :triggerType => "FORMULA",
                      :source => "synchronous_action",
                      :trigger_id => "12345678900987654321abcd"
                    }],
                    :entity => {
                      :type => "USER",
                      :id => "23056"
                    }
                  },
                  {
                    :action_id => "12345678901234567890abcd",
                    :time => 1437421587410,
                    :triggers => [{
                      :triggerType => "FORMULA",
                      :source => "synchronous_action",
                      :trigger_id => "abcd12345678901234567890"
                    }],
                    :entity => {
                      :type => "ORDER",
                      :id => "order_at_ 1437421587009"
                    }
                  }],
      :status => 0,
      :error_message => "OK"
    }
  end

  def fully_qualified_api_endpoint
    Sift::Client::API_ENDPOINT + Sift.rest_api_path
  end

  it "Successfully submits a v203 event with overridden key" do
    response_json = { :status => 0, :error_message => "OK"}
    stub_request(:post, "https://api.siftscience.com/v203/events").
      with { | request|
        parsed_body = JSON.parse(request.body)
        expect(parsed_body).to include("$buyer_user_id" => "123456")
        expect(parsed_body).to include("$api_key" => "overridden")
      }.to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    response = Sift::Client.new(:api_key => api_key, :version => "203")
               .track(event, properties, :api_key => "overridden")
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end


  it "Successfully fetches a v203 score" do

    api_key = "foobar"
    response_json = score_response_json

    stub_request(:get, "https://api.siftscience.com/v203/score/247019/?api_key=foobar")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    response = Sift::Client.new(:api_key => api_key)
               .score(score_response_json[:user_id], :version => 203)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

    expect(response.body["score"]).to eq(0.93)
  end


  it "Successfully fetches a v203 score with an overridden key" do

    api_key = "foobar"
    response_json = score_response_json

    stub_request(:get, "https://api.siftscience.com/v203/score/247019/?api_key=overridden")
      .to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    response = Sift::Client.new(:api_key => api_key, :version => 203)
               .score(score_response_json[:user_id], :api_key => "overridden")
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

    expect(response.body["score"]).to eq(0.93)
  end


  it "Successfuly make a v203 sync score request" do

    api_key = "foobar"
    response_json = {
      :status => 0,
      :error_message => "OK",
      :score_response => score_response_json
    }

    stub_request(:post, "https://api.siftscience.com/v203/events?return_score=true")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    event = "$transaction"
    properties = valid_transaction_properties
    response = Sift::Client.new(:api_key => api_key)
               .track(event, properties, :return_score => true, :version => "203")
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
    expect(response.body["score_response"]["score"]).to eq(0.93)
  end


  it "Successfuly make a v203 sync action request" do

    api_key = "foobar"
    response_json = {
      :status => 0,
      :error_message => "OK",
      :score_response => action_response_json
    }

    stub_request(:post, "https://api.siftscience.com/v203/events?return_action=true")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    event = "$transaction"
    properties = valid_transaction_properties
    response = Sift::Client.new(:api_key => api_key, :version => "203")
               .track(event, properties, :return_action => true)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
    expect(response.body["score_response"]["actions"].first["entity"]["type"]).to eq("USER")
  end

end
