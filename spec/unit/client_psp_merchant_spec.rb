require_relative "../spec_helper"
require "sift"

describe Sift::Client do

  before :each do
    Sift.api_key = nil
  end

  def post_psp_merchant_properties
    {
      "id": "api-key1-6",
      "name": "Wonderful Payments Inc.",
      "description": "Wonderful Payments payment provider.",
      "address": {
          "name": "Alany",
          "address_1": "Big Payment blvd, 22",
          "address_2": "apt, 8",
          "city": "New Orleans",
          "region": "NA",
          "country": "US",
          "zipcode": "76830",
          "phone": "0394888320"
      },
      "category": "1002",
      "service_level": "Platinum",
      "status": "active",
      "risk_profile": {
          "level": "low",
          "score": 10
      }
    }
  end

  def put_psp_merchant_properties
    {
      "id": "api-key1-7",
      "name": "Wonderful Payments Inc.",
      "description": "Wonderful Payments payment provider.",
      "address": {
          "name": "Alany",
          "address_1": "Big Payment blvd, 22",
          "address_2": "apt, 8",
          "city": "New Orleans",
          "region": "NA",
          "country": "US",
          "zipcode": "76830",
          "phone": "0394888320"
      },
      "category": "1002",
      "service_level": "Platinum",
      "status": "active",
      "risk_profile": {
          "level": "low",
          "score": 10
      }
    }
  end

  it "Successfully sumit create psp merchant" do
    api_key = "foobar1"

    response_json = { :status => 0, :error_message => "OK" }

    stub_request(:post, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/psp_management/merchants")
      .to_return(:status => 200, :body => MultiJson.dump(response_json))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT").create_psp_merchant_profile(post_psp_merchant_properties)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end

  it "Successfully submit update psp merchant" do
    api_key = "foobar1"
    merchant_id = "api-key1-7"

    response_json = { :status => 0, :error_message => "OK"}

    stub_request(:put, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/psp_management/merchants/api-key1-7")
      .to_return(:status => 200, :body => MultiJson.dump(response_json))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT").update_psp_merchant_profile(merchant_id, put_psp_merchant_properties)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end

  it "Successfully get a psp merchant profile" do
    api_key = "foobar1"
    merchant_id = "api-key1-7"

    response_json = { :status => 0, :error_message => "OK"}

    stub_request(:get, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/psp_management/merchants/api-key1-7")
      .to_return(:status => 200, :body => MultiJson.dump(response_json))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT").get_a_psp_merchant_profile(merchant_id)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end

  it "Successfully get all psp merchant profile with batch size" do
    api_key = "foobar1"

    response_json = { :status => 0, :error_message => "OK"}

    stub_request(:get, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/psp_management/merchants?batch_size=2")
      .to_return(:status => 200, :body => MultiJson.dump(response_json))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT").get_psp_merchant_profiles(2)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end

  it "Successfully get all psp merchant profile with batch size and batch token" do
    api_key = "foobar1"
    batch_size =  2
    batch_token = "batch_token"
    response_json = { :status => 0, :error_message => "OK"}

    stub_request(:get, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/psp_management/merchants?batch_size=2&batch_token=batch_token")
      .to_return(:status => 200, :body => MultiJson.dump(response_json))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT").get_psp_merchant_profiles(batch_size, batch_token)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
  end

end
