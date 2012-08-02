require 'httparty'
require 'multi_json'

module Sift

  # Represents the payload returned from a call through the track API
  #
  class Response
    attr_reader :json
    attr_reader :http_status_code
    attr_reader :api_status
    attr_reader :api_error_message
    attr_reader :original_request

    # Constructor
    #
    # == Parameters:
    # http_response
    #   The HTTP body text returned from the API call. The body is expected to be
    #   a JSON object that can be decoded into status, message and request 
    #   sections.
    #
    def initialize(http_response, http_response_code)
      @json = MultiJson.load(http_response)
      @original_request = MultiJson.load(@json["request"].to_s) if @json["request"]
      @http_status_code = http_response_code
      @api_status = @json["status"].to_i
      @api_error_message = @json["error_message"].to_s
    end

    # Helper method returns true if and only if the response from the API call was
    # successful
    #
    # == Returns:
    #   true on success; false otherwise
    def ok?
      0 == @api_status.to_i
    end
  end

  # This class wraps accesses through the API
  #
  class Client
    API_ENDPOINT = "https://api.siftscience.com"
    API_TIMEOUT = 2

    include HTTParty
    base_uri API_ENDPOINT
    default_timeout API_TIMEOUT

    # Constructor
    #
    # == Parameters:
    # api_key
    #   The Sift Science API key associated with your customer account. This parameter
    #   cannot be nil or blank.
    # path
    #   The path to the event API, e.g., "/v201/events"
    #
    def initialize(api_key, path = Sift.current_rest_api_path)
      @api_key = api_key.to_s
      @path = path
      raise(RuntimeError, "api_key is required") if @api_key.nil? || @api_key.empty?
    end

    # Tracks an event and associated properties through the Sift Science API. This call
    # is blocking.
    #
    # == Parameters:
    # event
    #   The name of the event to send. This can be either a reserved event name, like
    #   $transaction or $label or a custom event name (that does not start with a $).
    #   This parameter must be specified.
    #
    # properties
    #   A hash of name-value pairs that specify the event-specific attributes to track.
    #   This parameter must be specified.
    #
    # timeout
    #   The number of seconds to wait before failing the request. By default this is
    #   configured to 2 seconds (see above). This parameter is optional.
    #
    # == Returns:
    #   In the case of an HTTP error (timeout, broken connection, etc.), this
    #   method returns nil; otherwise, a Response object is returned and captures
    #   the status message and status code. In general, you can ignore the returned
    #   result, though.
    #
    def track(event, properties = {}, timeout = nil)

      raise(RuntimeError, "event must be a string") if event.nil? || event.to_s.empty?
      raise(RuntimeError, "properties cannot be empty") if properties.empty?

      options = {
        :body => MultiJson.dump(properties.merge({"$type" => event, 
                                                  "$api_key" => @api_key})),
      }
      options.merge!(:timeout => timeout) unless timeout.nil?
      begin
        response = self.class.post(@path, options)
        Response.new(response.body, response.code)
      rescue StandardError => e
        Sift.warn("Failed to track event: " + e.to_s)
        Sift.warn(e.backtrace)
      end
    end
  end
end
