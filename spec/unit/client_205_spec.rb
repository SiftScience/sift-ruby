require_relative '../spec_helper'
require 'sift'

describe Sift::Client do

  before :each do
    Sift.api_key = nil
  end

  def valid_transaction_properties
    {
      :$type => "$add_item_to_cart",
      :$user_id => "haneeshv@exalture.com",
      :$session_id => "gigtleqddo84l8cm15qe4il",
      :$item => {
        :$item_id => "B004834GQO",
        :$product_title => "The Slanket Blanket-Texas Tea",
        :$price => 39990000,
        :$currency_code => "USD",
        :$upc => "6786211451001",
        :$sku => "004834GQ",
        :$brand => "Slanket",
        :$manufacturer => "Slanket",
        :$category => "Blankets & Throws",
        :$tags => [
              "Awesome",
              "Wintertime specials"
        ],
        :$color => "Texas Tea",
        :$quantity => 16
      },
      :$brand_name => "sift",
      :$site_domain => "sift.com",
      :$site_country => "US",
      :$browser => {
        :$user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
        :$accept_language => "en-US",
        :$content_language => "en-GB"
      }
    }
  end

  def percentile_response_json
    {
      :user_id => 'haneeshv@exalture.com',
      :latest_labels => {},
      :workflow_statuses => [],
      :scores => {
        :account_abuse => {
          :score => 0.32787917675535705,
          :reasons => [{
            :name => 'Latest item product title',
            :value => 'The Slanket Blanket-Texas Tea'
          }],
          :percentiles => {
            :last_7_days => -1.0, :last_1_days => -1.0, :last_10_days => -1.0, :last_5_days => -1.0
          }
        },
        :acontent_abuse => {
          :score => 0.28056292905897995,
          :reasons => [{
            :name => 'timeSinceFirstEvent',
            :value => '13.15 minutes'
          }],
          :percentiles => {
            :last_7_days => -1.0, :last_1_days => -1.0, :last_10_days => -1.0, :last_5_days => -1.0
          }
        },
        :payment_abuse => {
          :score => 0.28610507028376797,
          :reasons => [{
            :name => 'Latest item currency code',
            :value => 'USD'
          }, {
            :name => 'Latest item item ID',
            :value => 'B004834GQO'
          }, {
            :name => 'Latest item product title',
            :value => 'The Slanket Blanket-Texas Tea'
          }],
          :percentiles => {
            :last_7_days => -1.0, :last_1_days => -1.0, :last_10_days => -1.0, :last_5_days => -1.0
          }
        },
        :promotion_abuse => {
          :score => 0.05731508921450917,
          :percentiles => {
            :last_7_days => -1.0, :last_1_days => -1.0, :last_10_days => -1.0, :last_5_days => -1.0
          }
        }
      },
      :status => 0,
      :error_message => 'OK'
    }
  end

  it "Successfully submits a v205 event with SCORE_PERCENTILES" do
    response_json =
    { :status => 0, :error_message => "OK",  :score_response => percentile_response_json}
    stub_request(:post, "https://api.siftscience.com/v205/events?fields=SCORE_PERCENTILES&return_score=true").
      with { | request|
        parsed_body = JSON.parse(request.body)
        expect(parsed_body).to include("$api_key" => "overridden")
      }.to_return(:status => 200, :body => MultiJson.dump(response_json), :headers => {})

    api_key = "foobar"
    event = "$transaction"
    properties = valid_transaction_properties

    response = Sift::Client.new(:api_key => api_key, :version => "205")
              .track(event, properties, :api_key => "overridden", :include_score_percentiles => "true", :return_score => "true")
    expect(response.ok?).to eq(true)
    expect(response.api_status).to eq(0)
    expect(response.api_error_message).to eq("OK")
    expect(response.body["score_response"]["scores"]["account_abuse"]["percentiles"]["last_7_days"]).to eq(-1.0)
  end
end