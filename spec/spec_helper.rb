$LOAD_PATH << Dir.pwd

require "bundler/setup"
require "webmock/rspec"

# Setup Fakeweb
WebMock.disable_net_connect!

RSpec.configure do |config|
end
