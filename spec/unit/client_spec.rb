require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

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

  def fully_qualified_api_endpoint
    Sift::Client::API_ENDPOINT + Sift.current_rest_api_path
  end

  it "Can instantiate client with blank api key if Sift.api_key set" do
    Sift.api_key = "test_global_api_key"
    Sift::Client.new().api_key.should eq(Sift.api_key)
  end

  it "Parameter passed api key takes precedence over Sift.api_key" do
    Sift.api_key = "test_global_api_key"
    api_key = "test_local_api_key"
    Sift::Client.new(api_key).api_key.should eq(api_key)
  end

  it "Cannot instantiate client with nil, empty, non-string, or blank api key" do
    lambda { Sift::Client.new(nil) }.should raise_error
    lambda { Sift::Client.new("") }.should raise_error
    lambda { Sift::Client.new(123456) }.should raise_error
    lambda { Sift::Client.new() }.should raise_error
  end

  it "Cannot instantiate client with nil, empty, non-string, or blank path" do
    api_key = "test_local_api_key"
    lambda { Sift::Client.new(api_key, nil) }.should raise_error
    lambda { Sift::Client.new(api_key, "") }.should raise_error
    lambda { Sift::Client.new(api_key, 123456) }.should raise_error
  end

  it "Can instantiate client with non-default timeout" do
    lambda { Sift::Client.new("test_local_api_key", Sift.current_rest_api_path, 4) }.should_not raise_error
  end

  it "Track call must specify an event name" do
    lambda { Sift::Client.new("foo").track(nil) }.should raise_error
    lambda { Sift::Client.new("foo").track("") }.should raise_error
  end

  it "Must specify an event name" do
    lambda { Sift::Client.new("foo").track(nil) }.should raise_error
    lambda { Sift::Client.new("foo").track("") }.should raise_error
  end

  it "Must specify properties" do
    event = "custom_event_name"
    lambda { Sift::Client.new("foo").track(event) }.should raise_error
  end

  it "Score call must specify a user_id" do
    lambda { Sift::Client.new("foo").score(nil) }.should raise_error
    lambda { Sift::Client.new("foo").score("") }.should raise_error
  end

  it "Doesn't raise an exception on Net/HTTP errors" do

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    stub_request(:any, /.*/).to_return(:status => 401)

    # This method should just return nil -- the track call failed because
    # of an HTTP error
    Sift::Client.new(api_key).track(event, properties).should eq(nil)
  end

  it "Returns nil when a StandardError occurs within the request" do

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    stub_request(:any, /.*/).to_raise(StandardError)

    # This method should just return nil -- the track call failed because
    # a StandardError exception was thrown
    Sift::Client.new(api_key).track(event, properties).should eq(nil)
  end

  it "Successfuly handles an event and returns OK" do

    response_json = { :status => 0, :error_message => "OK" }

    stub_request(:post, "https://api.siftscience.com/v203/events").
      with { |request|
        parsed_body = JSON.parse(request.body)
        parsed_body.should include("$buyer_user_id" => "123456")
      }.to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    response = Sift::Client.new(api_key).track(event, properties)
    response.ok?.should eq(true)
    response.api_status.should eq(0)
    response.api_error_message.should eq("OK")
  end

  it "Successfuly scrubs nils" do

    response_json = { :status => 0, :error_message => "OK" }

    stub_request(:post, "https://api.siftscience.com/v203/events").
      with { |request|
        parsed_body = JSON.parse(request.body)
        parsed_body.should_not include("fake_property")
        parsed_body.should include("sub_object" => {"one" => "two"})
      }.to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties.merge(
      "fake_property" => nil,
      "sub_object" => {
        "one" => "two",
        "three" => nil
      }
    )
    response = Sift::Client.new(api_key).track(event, properties)
    response.ok?.should eq(true)
    response.api_status.should eq(0)
    response.api_error_message.should eq("OK")
  end

  it "Successfully fetches a score" do

    api_key = "foobar"
    response_json = score_response_json

    stub_request(:get, "https://api.siftscience.com/v203/score/247019/?api_key=foobar").
      to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    response = Sift::Client.new(api_key).score(score_response_json[:user_id])
    response.ok?.should eq(true)
    response.api_status.should eq(0)
    response.api_error_message.should eq("OK")

    response.body["score"].should eq(0.93)
  end

  it "Successfuly make a sync score request" do

    api_key = "foobar"
    response_json = {
      :status => 0,
      :error_message => "OK",
      :score_response => score_response_json
    }

    stub_request(:post, "https://api.siftscience.com/v203/events?return_score=true").
      to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    event = "$transaction"
    properties = valid_transaction_properties
    response = Sift::Client.new(api_key).track(event, properties, nil, nil, true)
    response.ok?.should eq(true)
    response.api_status.should eq(0)
    response.api_error_message.should eq("OK")
    response.body["score_response"]["score"].should eq(0.93)
  end

end
