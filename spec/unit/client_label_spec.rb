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

    FakeWeb.register_uri(:post, fully_qualified_users_labels_endpoint(user_id),
                         :body => MultiJson.dump(response_json),
                         :status => [Net::HTTPOK, "OK"],
                         :content_type => "text/json")

    api_key = "foobar"
    properties = valid_label_properties

    response = Sift::Client.new(api_key).label(user_id, properties)
    response.ok?.should eq(true)
    response.api_status.should eq(0)
    response.api_error_message.should eq("OK")
  end

end
