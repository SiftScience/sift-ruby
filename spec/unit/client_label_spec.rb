require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe Sift::Client do

  def valid_label_properties
    {
      :$reasons => [ "$fake" ],
      :$is_bad => true,
      :$description => "Listed a fake item"
    }
  end

  def fully_qualified_users_labels_endpoint(user_id)
    Sift::Client::API_ENDPOINT + Sift.current_users_label_api_path(user_id)
  end

  it "Successfuly handles a $label with the v203 API and returns OK" do

    response_json = { :status => 0, :error_message => "OK" }
    user_id = "frodo_baggins"

    stub_request(:post, "https://api.siftscience.com/v203/users/frodo_baggins/labels").
      with(:body => '{"$reasons":["$fake"],"$is_bad":true,"$description":"Listed a fake item","$type":"$label","$api_key":"foobar"}').
      to_return(:body => MultiJson.dump(response_json), :status => 200, :content_type => "text/json")

    api_key = "foobar"
    properties = valid_label_properties

    response = Sift::Client.new(api_key).label(user_id, properties)
    response.ok?.should eq(true)
    response.api_status.should eq(0)
    response.api_error_message.should eq("OK")
  end

end
