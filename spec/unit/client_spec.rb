require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe Sift::Client do

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
      :$buyer_email => "mike@example.com"
    }
  end

  def fully_qualified_api_endpoint
    Sift::Client::API_ENDPOINT + Sift.current_rest_api_path
  end

  it "Cannot instantiate client with nil or blank api key" do
    lambda { Sift::Client.new(nil) }.should raise_error
    lambda { Sift::Client.new("") }.should raise_error
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

  it "Doesn't raise an exception on Net/HTTP errors" do

    FakeWeb.register_uri(:post, fully_qualified_api_endpoint,
                         :body => nil, :exception => Net::HTTPError)

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    # This method should just return false -- the track call failed because
    # of an HTTP error
    Sift::Client.new(api_key).track(event, properties).should eq(nil)
  end

  it "Successfuly handles an event and returns OK" do

    response_json = { :status => 0, :message => "OK" }

    FakeWeb.register_uri(:post, fully_qualified_api_endpoint,
                         :body => MultiJson.dump(response_json),
                         :status => [Net::HTTPOK, "OK"],
                         :content_type => "text/json")

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    response = Sift::Client.new(api_key).track(event, properties)
    response.ok?.should eq(true)
    response.api_status.should eq(0)
    response.api_status_message.should eq("OK")
  end

end
