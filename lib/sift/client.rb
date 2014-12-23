require 'httparty'
require 'multi_json'

module Sift

  

  # Represents the payload returned from a call through the track API
  #
  class Response
    attr_reader :body
    attr_reader :http_status_code
    attr_reader :api_status
    attr_reader :api_error_message
    attr_reader :request

    HTTP_CODES_WITH_NO_BODY = [204,304].freeze

    # Constructor
    #
    # == Parameters:
    # http_response
    #   The HTTP body text returned from the API call. The body is expected to be
    #   a JSON object that can be decoded into status, message and request
    #   sections.
    #
    def initialize(http_response, http_headers, http_response_code)
      @http_status_code = http_response_code

      # only set these variables if a message-body is expected.
      unless Response::HTTP_CODES_WITH_NO_BODY.include? @http_status_code
        @body = MultiJson.load(http_response) unless http_response.nil?
        @request = MultiJson.load(@body["request"].to_s) if @body["request"]
        @api_status = @body["status"].to_i if @body["status"]
        @api_error_message = @body["error_message"].to_s if @body["error_message"]
      end
    end

    # Helper method returns true if and only if the response from the API call was
    # successful
    #
    # == Returns:
    #   true on success; false otherwise
    def ok?
      #if there is no content expected, use HTTP code
      if Response::HTTP_CODES_WITH_NO_BODY.include? @http_status_code
        204 == @http_status_code
      # otherwise use API status
      else
        0 == @api_status.to_i 
      end
    end


    # DEPRECIATED
    # Getter method for depreciated 'json' member variable.
    def json
      @body
    end

    # DEPRECIATED
    # Getter method for depreciated 'original_request' member variable.
    def original_request
      @request
    end
  end

  # This class wraps accesses through the API
  #
  class Client
    API_ENDPOINT = "https://api.siftscience.com"
    API_TIMEOUT = 2

    include HTTParty
    base_uri API_ENDPOINT

    # Constructor
    #
    # == Parameters:
    # api_key
    #   The Sift Science API key associated with your customer account. This parameter
    #   cannot be nil or blank.
    # path
    #   The path to the event API, e.g., "/v201/events"
    #
    def initialize(api_key = Sift.api_key, path = Sift.current_rest_api_path, timeout = API_TIMEOUT)
      raise(RuntimeError, "api_key must be a non-empty string") if (!api_key.is_a? String) || api_key.empty?
      raise(RuntimeError, "path must be a non-empty string") if (!path.is_a? String) || path.empty?
      @api_key = api_key
      @path = path
      @timeout = timeout


    end

    def api_key
      @api_key
    end

    def user_agent
      "SiftScience/v#{API_VERSION} sift-ruby/#{VERSION}"
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
    # timeout (optional)
    #   The number of seconds to wait before failing the request. By default this is
    #   configured to 2 seconds (see above). This parameter is optional.
    #
    # path (optional)
    #   Overrides the default API path with a different URL.
    #
    # return_score (optional)
    #   Whether the API response should include a score for this user (the score will
    #   be calculated using the submitted event
    #
    # == Returns:
    #   In the case of an HTTP error (timeout, broken connection, etc.), this
    #   method returns nil; otherwise, a Response object is returned and captures
    #   the status message and status code. In general, you can ignore the returned
    #   result, though.
    #
    def track(event, properties = {}, timeout = nil, path = nil, return_score = false, api_key = @api_key)
      raise(RuntimeError, "event must be a non-empty string") if (!event.is_a? String) || event.empty?
      raise(RuntimeError, "properties cannot be empty") if properties.empty?
      raise(RuntimeError, "Bad api_key parameter") if api_key.empty?
      path ||= @path
      timeout ||= @timeout
      if return_score
        path = path + "?return_score=true"
      end
      options = {
        :body => MultiJson.dump(delete_nils(properties).merge({"$type" => event,
                                                               "$api_key" => api_key})),
        :headers => {"User-Agent" => user_agent}
      }
      options.merge!(:timeout => timeout) unless timeout.nil?
      begin
        response = self.class.post(path, options)
        Response.new(response.body, response.headers, response.code)
      rescue StandardError => e
        Sift.warn("Failed to track event: " + e.to_s)
        Sift.warn(e.backtrace)
        nil
      end
    end

    # Retrieves a user's fraud score from the Sift Science API. This call
    # is blocking.
    #
    # == Parameters:
    # user_id
    #   A user's id. This id should be the same as the user_id used in
    #   event calls.
    #
    # == Returns:
    #   A Response object is returned and captures the status message and
    #   status code. In general, you can ignore the returned result, though.
    #
    def score(user_id, timeout = nil, api_key = @api_key)

      raise(RuntimeError, "user_id must be a non-empty string") if (!user_id.is_a? String) || user_id.to_s.empty?
      raise(RuntimeError, "Bad api_key parameter") if api_key.empty?
      timetout ||= @timeout

      options = { :headers => {"User-Agent" => user_agent} }
      options.merge!(:timeout => timeout) unless timeout.nil?

      response = self.class.get("/v#{API_VERSION}/score/#{user_id}/?api_key=#{api_key}", options)
      Response.new(response.body, response.headers, response.code)

    end

    # Labels a user as either good or bad. This call is blocking.
    #
    # == Parameters:
    # user_id
    #   A user's id. This id should be the same as the user_id used in
    #   event calls.
    #
    # properties
    #   A hash of name-value pairs that specify the label attributes.
    #   This parameter must be specified.
    #
    # timeout (optional)
    #   The number of seconds to wait before failing the request. By default this is
    #   configured to 2 seconds (see above). This parameter is optional.
    #
    # == Returns:
    #   A Response object is returned and captures the status message and
    #   status code. In general, you can ignore the returned result, though.
    #
    def label(user_id, properties = {}, timeout = nil, api_key = @api_key)

      raise(RuntimeError, "user_id must be a non-empty string") if (!user_id.is_a? String) || user_id.to_s.empty?

      path = Sift.current_users_label_api_path(user_id)
      track("$label", delete_nils(properties), timeout, path, false, api_key)
    end

    # Unlabels a user.  This call is blocking.
    #
    # == Parameters:
    # user_id
    #   A user's id. This id should be the same as the user_id used in
    #   event calls.
    #
    # timeout (optional)
    #   The number of seconds to wait before failing the request. By default this is
    #   configured to 2 seconds (see above). This parameter is optional.
    #
    # == Returns:
    #   A Response object is returned with only an http code of 204.
    #
    def unlabel(user_id, timeout = nil)

      raise(RuntimeError, "user_id must be a non-empty string") if (!user_id.is_a? String) || user_id.to_s.empty?
      timetout ||= @timeout

      options = { :headers => {"User-Agent" => user_agent} }
      options.merge!(:timeout => timeout) unless timeout.nil?
      path = Sift.current_users_label_api_path(user_id)
      response = self.class.delete(path + "?api_key=#{@api_key}", options)
      Response.new(response.body, response.headers, response.code)

    end

    private
    def delete_nils(properties)
      properties.delete_if do |k, v|
        case v
        when nil
          true
        when Hash
          delete_nils(v)
          false
        else
          false
        end
      end
    end
  end
end
