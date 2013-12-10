
require "bundler/setup"
require "sift"
require "webmock/rspec"

# Setup Fakeweb
WebMock.disable_net_connect!

RSpec.configure do |config|
end
