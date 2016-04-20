require_relative "../spec_helper"

RSpec.describe Sift::Device, :with_configs do
  let(:device_json) { read_mock_response("devise.json") }
  let(:request_headers) { Sift::RestWrapper.send(:default_options) }
  let(:stubbed_response) {
    {
      body: device_json,
      status: 200,
      headers: {"content-type"=>"application/json; charset=UTF-8"}
    }
  }

  let(:device) { Sift::Device.new(id: 'device_id') }

  it('#url') do
    expect(device.url).to eq(Sift::RestWrapper.base_url + "/devices/device_id")
  end

  describe ".retrieve" do
    let(:device) { Sift::Device.retrieve('device_id') }

    it "will fetch device info" do
      stub_request(:get, "https://api3.siftscience.com/v3/accounts/#{Sift.account_id}/devices/device_id")
        .with(request_headers)
        .to_return(stubbed_response)

      expect(device.id).to eq("device_id")
      expect(device.first_seen).to eq(Time.at(1433869933))
      expect(device.label).to eq("bad")
      expect(device.labeled_at).to eq(Time.at(1434042758))
      expect(device.network).to_not be_nil
      expect(device.network.first_seen).to eq(Time.at(1433440739))
      expect(device.network.score).to eq(0.5)
      expect(device.sessions.data).
        to eq([Sift::Entities::Blank.new(:time => Time.at(1433987326))])
    end
  end

  describe '#label_bad!' do
    it "will mark device bad" do
      stub_request(:put, device.send(:url) + "/label")
        .to_return({ body: '{ "label": "bad" }' })

      expect(device.labeled?).to eq(false)

      device.label_bad!
      expect(device.labeled?).to eq(true)
      expect(device.bad?).to eq(true)
    end
  end

  describe '#label_not_bad!' do
    it "will mark device bad" do
      stub_request(:put, device.send(:url) + "/label")
        .to_return({ body: '{ "label": "not_bad" }' })

      expect(device.labeled?).to eq(false)

      device.label_not_bad!
      expect(device.labeled?).to eq(true)
      expect(device.not_bad?).to eq(true)
    end
  end
end
