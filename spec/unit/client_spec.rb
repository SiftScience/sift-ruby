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

  def user_score_response_json
    {
      :entity_type => "user",
      :entity_id => "247019",
      :scores => {
        :payment_abuse => {
          :score => 0.78
        },
        :content_abuse => {
          :score => 0.11
        }
      },
      :latest_decisions => {
        :payment_abuse => {
          :id => "user_looks_bad_payment_abuse",
          :category => "block",
          :source => "AUTOMATED_RULE",
          :time => 1352201880,
          :description => "Bad Fraudster"
        }
      },
      :latest_labels => {
        :payment_abuse => {
          :is_bad => true,
          :time => 1352201880
        }
      },
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


  it "Can instantiate client with blank api key if Sift.api_key set" do
    Sift.api_key = "test_global_api_key"
    expect(Sift::Client.new().api_key).to eq(Sift.api_key)
  end


  it "Parameter passed api key takes precedence over Sift.api_key" do
    Sift.api_key = "test_global_api_key"
    api_key = "test_local_api_key"
    expect(Sift::Client.new(:api_key => api_key).api_key).to eq(api_key)
  end


  it "Cannot instantiate client with nil, empty, non-string, or blank api key" do
    expect(lambda { Sift::Client.new(:api_key => nil) }).to raise_error(StandardError)
    expect(lambda { Sift::Client.new(:api_key => "") }).to raise_error(StandardError)
    expect(lambda { Sift::Client.new(:api_key => 123456) }).to raise_error(StandardError)
    expect(lambda { Sift::Client.new() }).to raise_error(StandardError)
  end


  it "Cannot instantiate client with empty, non-string, or blank path" do
    expect(lambda { Sift::Client.new(:path => "") }).to raise_error(StandardError)
    expect(lambda { Sift::Client.new(:path => 123456) }).to raise_error(StandardError)
  end


  it "Can instantiate client with non-default timeout" do
    expect(lambda { Sift::Client.new(:api_key => "foo", :timeout => 4) })
      .not_to raise_error
  end


  it "Track call must specify an event name" do
    expect(lambda { Sift::Client.new().track(nil) }).to raise_error(StandardError)
    expect(lambda { Sift::Client.new().track("") }).to raise_error(StandardError)
  end


  it "Must specify an event name" do
    expect(lambda { Sift::Client.new().track(nil) }).to raise_error(StandardError)
    expect(lambda { Sift::Client.new().track("") }).to raise_error(StandardError)
  end


  it "Must specify properties" do
    event = "custom_event_name"
    expect(lambda { Sift::Client.new().track(event) }).to raise_error(StandardError)
  end


  it "Score call must specify a user_id" do
    expect(lambda { Sift::Client.new().score(nil) }).to raise_error(StandardError)
    expect(lambda { Sift::Client.new().score("") }).to raise_error(StandardError)
  end


  it "Doesn't raise an exception on Net/HTTP errors" do
    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties
    res = nil

    stub_request(:any, /.*/).to_return(:status => 401)

    expect { res = Sift::Client.new(:api_key => api_key).track(event, properties) }.not_to raise_error
    expect(res.http_status_code).to eq(401)
  end


  it "Propagates exception when a StandardError occurs within the request" do
    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    stub_request(:any, /.*/).to_raise(StandardError)

    # This method should propagate the StandardError exception
    expect { Sift::Client.new(:api_key => api_key).track(event, properties) }.to raise_error(StandardError)
  end


  it "Successfuly handles an event and returns OK" do
    response_json = { :status => 0, :error_message => "OK" }

    stub_request(:post, "https://api.siftscience.com/v205/events").
      with { |request|
        parsed_body = JSON.parse(request.body)
        expect(parsed_body).to include("$buyer_user_id" => "123456")
    }.to_return(:status => 200, :body => MultiJson.dump(response_json),
                :headers => {"content-type"=>"application/json; charset=UTF-8",
                             "content-length"=> "74"})

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    response = Sift::Client.new(:api_key => api_key).track(event, properties)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end


  it "Successfully submits event with overridden key" do
    response_json = { :status => 0, :error_message => "OK"}
    stub_request(:post, "https://api.siftscience.com/v205/events").
      with { | request|
        parsed_body = JSON.parse(request.body)
        expect(parsed_body).to include("$buyer_user_id" => "123456")
        expect(parsed_body).to include("$api_key" => "overridden")
      }.to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    response = Sift::Client.new(:api_key => api_key)
               .track(event, properties, :api_key => "overridden")
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end


  it "Successfully scrubs nils" do
    response_json = { :status => 0, :error_message => "OK" }

    stub_request(:post, "https://api.siftscience.com/v205/events")
      .with { |request|
        parsed_body = JSON.parse(request.body)
        expect(parsed_body).not_to include("fake_property")
        expect(parsed_body).to include("sub_object" => {"one" => "two"})
    }.to_return(:status => 200, :body => MultiJson.dump(response_json),
                :headers => {"content-type"=>"application/json; charset=UTF-8",
                             "content-length"=> "74"})

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties.merge(
      "fake_property" => nil,
      "sub_object" => {
        "one" => "two",
        "three" => nil
      }
    )
    response = Sift::Client.new(:api_key => api_key).track(event, properties)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end


  it "Successfully fetches a score" do
    api_key = "foobar"
    response_json = score_response_json

    stub_request(:get, "https://api.siftscience.com/v205/score/247019/?api_key=foobar")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    response = Sift::Client.new(:api_key => api_key).score(score_response_json[:user_id])
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

    expect(response.body["score"]).to eq(0.93)
  end


  it "Successfully fetches a score with an overridden key" do
    api_key = "foobar"
    response_json = score_response_json

    stub_request(:get, "https://api.siftscience.com/v205/score/247019/?api_key=overridden")
      .to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    response = Sift::Client.new(:api_key => api_key)
               .score(score_response_json[:user_id], :api_key => "overridden")
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

    expect(response.body["score"]).to eq(0.93)
  end


  it "Successfully executes client.get_user_score()" do
    api_key = "foobar"
    response_json = user_score_response_json

    stub_request(:get, "https://api.siftscience.com/v205/users/247019/score?api_key=foobar")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    response = Sift::Client.new(:api_key => api_key).get_user_score(user_score_response_json[:entity_id])
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

    expect(response.body["entity_id"]).to eq("247019")
    expect(response.body["scores"]["payment_abuse"]["score"]).to eq(0.78)
  end


  it "Successfully executes client.get_user_score() with abuse types specified" do
    api_key = "foobar"
    response_json = user_score_response_json

    stub_request(:get, "https://api.siftscience.com/v205/users/247019/score" +
                 "?api_key=foobar&abuse_types=content_abuse,payment_abuse")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    response = Sift::Client.new(:api_key => api_key).get_user_score(user_score_response_json[:entity_id],
                                                                    :abuse_types => ["content_abuse",
                                                                                     "payment_abuse"])
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

    expect(response.body["entity_id"]).to eq("247019")
    expect(response.body["scores"]["payment_abuse"]["score"]).to eq(0.78)
  end


  it "Successfully executes client.rescore_user()" do
    api_key = "foobar"
    response_json = user_score_response_json

    stub_request(:post, "https://api.siftscience.com/v205/users/247019/score?api_key=foobar")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    response = Sift::Client.new(:api_key => api_key).rescore_user(user_score_response_json[:entity_id])
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

    expect(response.body["entity_id"]).to eq("247019")
    expect(response.body["scores"]["payment_abuse"]["score"]).to eq(0.78)
  end


  it "Successfully executes client.rescore_user() with abuse types specified" do
    api_key = "foobar"
    response_json = user_score_response_json

    stub_request(:post, "https://api.siftscience.com/v205/users/247019/score" +
                 "?api_key=foobar&abuse_types=content_abuse,payment_abuse")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    response = Sift::Client.new(:api_key => api_key).rescore_user(user_score_response_json[:entity_id],
                                                                  :abuse_types => ["content_abuse",
                                                                                   "payment_abuse"])
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

    expect(response.body["entity_id"]).to eq("247019")
    expect(response.body["scores"]["payment_abuse"]["score"]).to eq(0.78)
  end


  it "Successfully make a sync score request" do
    api_key = "foobar"
    response_json = {
      :status => 0,
      :error_message => "OK",
      :score_response => score_response_json
    }

    stub_request(:post, "https://api.siftscience.com/v205/events?return_score=true")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    event = "$transaction"
    properties = valid_transaction_properties
    response = Sift::Client.new(:api_key => api_key)
               .track(event, properties, :return_score => true)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
    expect(response.body["score_response"]["score"]).to eq(0.93)
  end


  it "Successfully make a sync action request" do
    api_key = "foobar"
    response_json = {
      :status => 0,
      :error_message => "OK",
      :score_response => action_response_json
    }

    stub_request(:post, "https://api.siftscience.com/v205/events?return_action=true")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    event = "$transaction"
    properties = valid_transaction_properties
    response = Sift::Client.new(:api_key => api_key)
               .track(event, properties, :return_action => true)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
    expect(response.body["score_response"]["actions"].first["entity"]["type"]).to eq("USER")
  end


  it "Successfully make a sync workflow request" do
    api_key = "foobar"
    response_json = {
      :status => 0,
      :error_message => "OK",
      :score_response => {
        :status => -1,
        :error_message => "Internal server error."
      }
    }

    stub_request(:post,
                 "https://api.siftscience.com/v205/events?return_workflow_status=true&abuse_types=legacy,payment_abuse")
      .to_return(:status => 200, :body => MultiJson.dump(response_json),
                 :headers => {"content-type"=>"application/json; charset=UTF-8",
                              "content-length"=> "74"})

    event = "$transaction"
    properties = valid_transaction_properties
    response = Sift::Client.new(:api_key => api_key)
               .track(event, properties,
                      :return_workflow_status => true, :abuse_types => ['legacy', 'payment_abuse'])
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end


  it "Successfully make a workflow status request" do
    response_text = '{"id":"skdjfnkse","config":{"id":"5rrbr4iaaa","version":"1468367620871"},"config_display_name":"workflow config","abuse_types":["payment_abuse"],"state":"running","entity":{"id":"example_user","type":"user"},"history":[{"app":"user","name":"Entity","state":"finished","config":{}}]}'

    stub_request(:get, "https://foobar:@api3.siftscience.com/v3/accounts/ACCT/workflows/runs/skdjfnkse")
      .to_return(:status => 200, :body => response_text, :headers => {})

    client = Sift::Client.new(:api_key => "foobar", :account_id => "ACCT")
    response = client.get_workflow_status("skdjfnkse")

    expect(response.ok?).to eq(true)
    expect(response.body["id"]).to eq("skdjfnkse")
    expect(response.body["state"]).to eq("running")
  end


  it "Successfully make a user decisions request" do
    response_text = '{"decisions":{"content_abuse":{"decision":{"id":"user_decision"},"time":1468707128659,"webhook_succeeded":false}}}'

    stub_request(:get, "https://foobar:@api3.siftscience.com/v3/accounts/ACCT/users/example_user/decisions")
      .to_return(:status => 200, :body => response_text, :headers => {})

    client = Sift::Client.new(:api_key => "foobar", :account_id => "ACCT")
    response = client.get_user_decisions("example_user")

    expect(response.ok?).to eq(true)
    expect(response.body["decisions"]["content_abuse"]["decision"]["id"]).to eq("user_decision")
  end


  it "Successfully make an order decisions request" do
    response_text = '{"decisions":{"payment_abuse":{"decision":{"id":"decision7"},"time":1468599638005,"webhook_succeeded":false},"promotion_abuse":{"decision":{"id":"good_order"},"time":1468517407135,"webhook_succeeded":true}}}'

    stub_request(:get, "https://foobar:@api3.siftscience.com/v3/accounts/ACCT/orders/example_order/decisions")
      .to_return(:status => 200, :body => response_text, :headers => {})

    client = Sift::Client.new(:api_key => "foobar", :account_id => "ACCT")
    response = client.get_order_decisions("example_order", :timeout => 3)

    expect(response.ok?).to eq(true)
    expect(response.body["decisions"]["payment_abuse"]["decision"]["id"]).to eq("decision7")
  end

  it "Successfully make a session decisions request" do
    response_text = '{"decisions":{"account_takeover":{"decision":{"id":"session_decision"},"time":1468707128659,"webhook_succeeded":false}}}'

    stub_request(:get, "https://foobar:@api3.siftscience.com/v3/accounts/ACCT/users/example_user/sessions/example_session/decisions")
      .to_return(:status => 200, :body => response_text, :headers => {})

    client = Sift::Client.new(:api_key => "foobar", :account_id => "ACCT")
    response = client.get_session_decisions("example_user", "example_session")

    expect(response.ok?).to eq(true)
    expect(response.body["decisions"]["account_takeover"]["decision"]["id"]).to eq("session_decision")
  end

  it "Successfully make an content decisions request" do
    response_text = '{"decisions":{"content_abuse":{"decision":{"id":"decision7"},"time":1468599638005,"webhook_succeeded":false}}}'

    stub_request(:get, "https://foobar:@api3.siftscience.com/v3/accounts/ACCT/users/USER/content/example_content/decisions")
      .to_return(:status => 200, :body => response_text, :headers => {})

    client = Sift::Client.new(:api_key => "foobar", :account_id => "ACCT")
    response = client.get_content_decisions("USER", "example_content", :timeout => 3)

    expect(response.ok?).to eq(true)
    expect(response.body["decisions"]["content_abuse"]["decision"]["id"]).to eq("decision7")
  end

end
