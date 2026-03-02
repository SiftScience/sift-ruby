require_relative "../spec_helper"
require "sift"
require "logger"

describe "Sift::Client Configuration Patterns" do
  let(:api_key) { "test_api_key" }

  it "propagates global Sift::Client configuration to internal clients" do
    Sift::Client.default_timeout 5
    
    # Internal executors should inherit this
    expect(Sift::Client.api_client.default_options[:timeout]).to eq(5)
    expect(Sift::Client.api3_client.default_options[:timeout]).to eq(5)
    
    # Reset
    Sift::Client.default_timeout 2
  end

  it "allows independent subclass configurations" do
    class SubclassA < Sift::Client; end
    class SubclassB < Sift::Client; end

    SubclassA.default_timeout 10
    SubclassB.default_timeout 20

    expect(SubclassA.api_client.default_options[:timeout]).to eq(10)
    expect(SubclassB.api_client.default_options[:timeout]).to eq(20)
    
    # Ensure they didn't leak to parent
    expect(Sift::Client.api_client.default_options[:timeout]).to be <= 5
  end

  it "propagates complex settings like loggers to subclasses" do
    class LoggingClient < Sift::Client; end
    
    logger = Logger.new(nil)
    LoggingClient.logger logger, :debug, :curl

    expect(LoggingClient.api_client.default_options[:logger]).to eq(logger)
    expect(LoggingClient.api_client.default_options[:log_level]).to eq(:debug)
    expect(LoggingClient.api_client.default_options[:log_format]).to eq(:curl)
    
    # Ensure Sift::Client remains untouched
    expect(Sift::Client.api_client.default_options[:logger]).to be_nil
  end

  it "respects inheritance chain for Decisions and Router" do
    class DecisionClient < Sift::Client; end
    DecisionClient.default_timeout 15

    client = DecisionClient.new(api_key: api_key, account_id: "acc")
    
    # Verify the executor used by the Router is the one from DecisionClient
    expect(DecisionClient.api3_client.default_options[:timeout]).to eq(15)

    # We want to ensure that when Router.get is called, it uses DecisionClient.api3_client
    # In lib/sift/router.rb, we have:
    # wrap_response(client_class.api3_client.get(path, options))
    
    expect(DecisionClient.api3_client).to receive(:get).and_call_original

    # Mock the request to avoid network calls
    stub_request(:get, /api3.siftscience.com/)
    
    client.get_user_decisions("user_1")
  end
end
