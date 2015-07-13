require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe Sift::Device do

  def session_json
    %q(
{
    "device": {
        "first_seen": 1433869933142,
        "id": "device_id",
        "label": "bad",
        "labeled_at": 1434042758141,
        "network": {
            "first_seen": 1433440739499,
            "score": 0.5
        },
        "sessions": {
            "data": [
                {
                    "time": 1433987326843
                }
            ],
            "has_more": false,
            "total_results": 1
        }
    },
    "id": "session_id",
    "time": 1433987326843
}
    )
  end

  def device_json
    %q(
{
    "first_seen": 1433869933142,
    "id": "device_id",
    "label": "bad",
    "labeled_at": 1434042758141,
    "network": {
        "first_seen": 1433440739499,
        "score": 0.5
    },
    "sessions": {
        "data": [
            {
                "time": 1433987326843
            }
        ],
        "has_more": false,
        "total_results": 1
    }
}
    )
  end

  def request_headers(api_key)
    { 
      #"Authorization" => "Basic #{api_key}",
      "Content-Type" => "application/json",
      "User-Agent" => "sift-ruby/#{Sift::VERSION}"
    }
  end

  it "can fetch a device" do

    Sift.api_key = "api_key"
    Sift.account_id = "account_id"

    # stub the http request
    stub_request(:get, "https://j%98%A4%7B@api3.siftscience.com/v3/accounts/#{Sift.account_id}/devices/device_id")
      .with(:headers => request_headers(Sift.api_key))
      .to_return(:body => device_json,
                 :status => 200,
                 :headers => {"content-type"=>"application/json; charset=UTF-8"})

    device = Sift::Device.retrieve("device_id")
    expect(device.id).to eq("device_id")
    expect(device.first_seen).to eq(Time.at(1433869933))
    expect(device.label).to eq("bad")
    expect(device.labeled_at).to eq(Time.at(1434042758))
    expect(device.network).to_not be_nil
    expect(device.network.first_seen).to eq(Time.at(1433440739))
    expect(device.network.score).to eq(0.5)
    expect(device.sessions.data).
      to eq([Sift::SessionTime.new(:time => Time.at(1433987326))])
  end

  it "can fetch a device" do

    Sift.api_key = "api_key"
    Sift.account_id = "account_id"

    # stub the http request
    stub_request(:get, "https://j%98%A4%7B@api3.siftscience.com/v3/accounts/#{Sift.account_id}/devices/device_id")
      .with(:headers => request_headers(Sift.api_key))
      .to_return(:body => device_json,
                 :status => 200,
                 :headers => {"content-type"=>"application/json; charset=UTF-8"})

    device = Sift::Device.retrieve("device_id")
    expect(device.id).to eq("device_id")
    expect(device.first_seen).to eq(Time.at(1433869933))
    expect(device.label).to eq("bad")
    expect(device.labeled_at).to eq(Time.at(1434042758))
    expect(device.network).to_not be_nil
    expect(device.network.first_seen).to eq(Time.at(1433440739))
    expect(device.network.score).to eq(0.5)
    expect(device.sessions.data).
      to eq([Sift::SessionTime.new(:time => Time.at(1433987326))])
  end
end
