require_relative '../spec_helper'
require 'sift'

describe Sift::Client do

  before :each do
    Sift.api_key = nil
  end

  it "Successfully submits a $create_account event with KYC, geo, and bot-detection structured fields" do
    response_json = { :status => 0, :error_message => "OK" }
    stub_request(:post, "https://api.siftscience.com/v205/events").
      with { |request|
        parsed_body = JSON.parse(request.body)
        expect(parsed_body["$nationality"]).to eq("US")
        expect(parsed_body["$year_of_birth"]).to eq(1985)
        expect(parsed_body["$kyc"]).to eq({
          "$names_match" => true,
          "$kyc_level" => "$basic",
          "$bin_nationality_match" => true,
          "$provider" => "lexisnexis"
        })
        expect(parsed_body["$geo"]).to eq({
          "$uuid" => "gc-abc-123",
          "$provider" => "geocomply"
        })
        expect(parsed_body["$bot_identification"]).to eq({
          "$result" => "$human",
          "$provider" => "datadome"
        })
      }.to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    api_key = "foobar"
    properties = {
      :$type => "$create_account",
      :$user_id => "23056",
      :$nationality => "US",
      :$year_of_birth => 1985,
      :$kyc => {
        :$names_match => true,
        :$kyc_level => "$basic",
        :$bin_nationality_match => true,
        :$provider => "lexisnexis"
      },
      :$geo => {
        :$uuid => "gc-abc-123",
        :$provider => "geocomply"
      },
      :$bot_identification => {
        :$result => "$human",
        :$provider => "datadome"
      }
    }

    response = Sift::Client.new(:api_key => api_key, :version => "205")
              .track("$create_account", properties)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
  end
end
