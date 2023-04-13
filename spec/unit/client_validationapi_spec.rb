require_relative "../spec_helper"
require "sift"

describe Sift::Client do

  before :each do
    Sift.api_key = nil
  end

  def valid_send_properties
    {
      :$user_id => 'billy_jones_301',
	    :$send_to => 'billy_jones_301@gmail.com',
      :$verification_type => '$email',
      :$brand_name => 'MyTopBrand',
      :$language => 'en',
      :$event => {
                :$session_id => '09f7f361575d11ff',
                :$verified_event => '$login',
                :$reason => '$automated_rule',
                :$ip => '192.168.1.1',
                :$browser => {
                    :$user_agent => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36'
                }
            }
    }
  end

  def valid_resend_properties
    {
      :$user_id => 'billy_jones_301',
      :$verified_event => '$login'
    }
  end

  def valid_check_properties
    {
      :$user_id => 'billy_jones_301',
      :$code => '123456'
    }
  end

  it "Successfully calls send" do
    api_key = "foobar1"
    user_id = "foobar2"

    response_json = { :status => 0, :error_message => "OK"}

    stub_request(:post, "https://foobar1:@api.siftscience.com/v1.1/verification/send")
      .to_return(:status => 200, :body => MultiJson.dump(response_json))

    response = Sift::Client.new(:api_key => api_key,:user_id => user_id,:version=>1.1).send(valid_send_properties,:version => 205)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

  end

  it "Successfully calls resend" do
    api_key = "foobar1"
    user_id = "foobar2"

    response_json = { :status => 0, :error_message => "OK"}

    stub_request(:post, "https://foobar1:@api.siftscience.com/v1.1/verification/resend")
      .to_return(:status => 200, :body => MultiJson.dump(response_json))

    response = Sift::Client.new(:api_key => api_key,:user_id => user_id,:version=>1.1).resend(valid_resend_properties,:version => 205)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

  end

  it "Successfully calls check" do
    api_key = "foobar1"
    user_id = "foobar2"

    response_json = { :status => 0, :error_message => "OK"}

    stub_request(:post, "https://foobar1:@api.siftscience.com/v1.1/verification/check")
      .to_return(:status => 200, :body => MultiJson.dump(response_json))

    response = Sift::Client.new(:api_key => api_key,:user_id => user_id,:version=>1.1).check(valid_check_properties,:version => 205)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")

  end

end