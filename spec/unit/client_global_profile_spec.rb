require_relative "../spec_helper"
require "sift"

describe Sift::Client do

  before :each do
    Sift.api_key = nil
  end

  def global_profile_response
    {
      :status => 0,
      :error_message => "OK",
      :error_code => nil,
      :lookback_months => 12,
      :profile_summary => {
        :identity_found => true,
        :has_links => true,
        :link_count => 7,
        :linked_accounts_count_per_industry => { :finances => 3, :internet => 4 }
      },
      :identity_age => {
        :oldest_account_age_timestamp => 1681090536,
        :newest_account_age_timestamp => 1881090536,
        :average_account_age_timestamp => 1781090536
      },
      :user_decisions => {
        :total => 12, :blocked => 2, :watched => 3, :accepted => 6,
        :manual => 4, :auto => 8, :last_type => "BLOCK", :last_timestamp => 1881090536
      },
      :chargebacks => {
        :total => 3, :fraudulent => 2, :other => 1,
        :last_timestamp => 1881090536, :last_fraudulent_timestamp => 1881090536
      },
      :orders => {
        :total => 50, :blocked => 2, :watched => 5, :accepted => 40,
        :last_timestamp => 1881090536, :last_blocked_timestamp => 1881090536
      },
      :transactions => {
        :total => 120, :failed_fraud => 3, :failed_other => 5, :successful => 112,
        :last_timestamp => 1881090536, :last_failed_fraud_timestamp => 1881090536
      },
      :locations => {
        :unique_billing_addresses => 2, :unique_shipping_addresses => 4,
        :distinct_countries_count => 3, :distinct_regions_count => 5,
        :location_connected_accounts => [{ :city => "Kyiv", :country => "UA" }],
        :location_last_used_timestamp => 1881090536
      }
    }
  end

  it "Successfully gets a Global Profile for a user" do
    api_key = "foobar1"

    stub_request(:get, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/global_profile/users/user1")
      .to_return(:status => 200, :body => MultiJson.dump(global_profile_response))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT").get_global_profile("user1")
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
    expect(response.body["profile_summary"]["link_count"]).to eq(7)
  end

  it "Successfully gets a Global Profile for a user with global_only and include_own_data" do
    api_key = "foobar1"

    stub_request(:get, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/global_profile/users/user1?global_only=true&include_own_data=false")
      .to_return(:status => 200, :body => MultiJson.dump(global_profile_response))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT")
      .get_global_profile("user1", :global_only => true, :include_own_data => false)
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
  end

  it "Raises when user_id is empty" do
    api_key = "foobar1"

    expect {
      Sift::Client.new(:api_key => api_key, :account_id => "ACCT").get_global_profile("")
    }.to raise_error(RuntimeError, "user_id must be a non-empty string")
  end

  it "Successfully looks up a Global Profile by email" do
    api_key = "foobar1"

    stub_request(:post, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/global_profile/lookup")
      .with(:body => MultiJson.dump({ "email" => "user@example.com" }))
      .to_return(:status => 200, :body => MultiJson.dump(global_profile_response))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT")
      .get_global_profile_by_attributes(:email => "user@example.com")
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
  end

  it "Successfully looks up a Global Profile by phone" do
    api_key = "foobar1"

    stub_request(:post, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/global_profile/lookup")
      .with(:body => MultiJson.dump({ "phone" => "+15555550100" }))
      .to_return(:status => 200, :body => MultiJson.dump(global_profile_response))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT")
      .get_global_profile_by_attributes(:phone => "+15555550100")
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
  end

  it "Successfully looks up a Global Profile by email and phone" do
    api_key = "foobar1"

    stub_request(:post, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/global_profile/lookup")
      .with(:body => MultiJson.dump({ "email" => "user@example.com", "phone" => "+15555550100" }))
      .to_return(:status => 200, :body => MultiJson.dump(global_profile_response))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT")
      .get_global_profile_by_attributes(:email => "user@example.com", :phone => "+15555550100")
    expect(response.ok?).to eq(true)
  end

  it "Raises when neither email nor phone is provided" do
    api_key = "foobar1"

    expect {
      Sift::Client.new(:api_key => api_key, :account_id => "ACCT").get_global_profile_by_attributes({})
    }.to raise_error(RuntimeError, "email or phone must be provided")
  end

  it "Handles identity_found => false with null fields" do
    api_key = "foobar1"

    response_json = {
      :status => 0,
      :error_message => "OK",
      :error_code => nil,
      :lookback_months => nil,
      :profile_summary => { :identity_found => false, :has_links => nil, :link_count => nil,
                             :linked_accounts_count_per_industry => nil },
      :identity_age => nil,
      :user_decisions => nil,
      :chargebacks => nil,
      :orders => nil,
      :transactions => nil,
      :locations => nil
    }

    stub_request(:get, "https://foobar1:@api.siftscience.com/v3/accounts/ACCT/global_profile/users/user2")
      .to_return(:status => 200, :body => MultiJson.dump(response_json))

    response = Sift::Client.new(:api_key => api_key, :account_id => "ACCT").get_global_profile("user2")
    expect(response.ok?).to eq(true)
    expect(response.body["profile_summary"]["identity_found"]).to eq(false)
    expect(response.body["identity_age"]).to be_nil
  end

end
