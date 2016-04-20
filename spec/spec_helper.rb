require "bundler/setup"
require "sift"
require "webmock/rspec"
require_relative "helpers/mock_responses/loader"

# Setup Fakeweb
WebMock.disable_net_connect!

RSpec.configure do |config|
  include MockResponsesLoader

  config.before(:example, :with_configs) do
    Sift.api_key = "api_key"
    Sift.account_id = "account_id"
  end
end
