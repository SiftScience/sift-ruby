require "httparty"
require "multi_json"
require "base64"

require_relative "./client/decision"
require_relative "./error"

module Sift

  # Represents the payload returned from a call through the track API
  #
  class Response
    attr_reader :body,
      :http_class,
      :http_status_code,
      :api_status,
      :api_error_message,
      :request,
      :api_error_description,
      :api_error_issues

    # Constructor
    #
    # ==== Parameters:
    #
    # http_response::
    #   The HTTP body text returned from the API call. The body is expected to be
    #   a JSON object that can be decoded into status, message and request
    #   sections.
    #
    def initialize(http_response, http_response_code, http_raw_response)
      @http_status_code = http_response_code
      @http_raw_response = http_raw_response

      # only set these variables if a message-body is expected.
      if not @http_raw_response.kind_of? Net::HTTPNoContent
        @body = MultiJson.load(http_response) unless http_response.nil?
        @request = MultiJson.load(@body["request"].to_s) if @body["request"]
        @api_status = @body["status"].to_i if @body["status"]
        @api_error_message = @body["error_message"]

        if @body["error"]
          @api_error_message = @body["error"]
          @api_error_description = @body["description"]
          @api_error_issues = @body["issues"] || {}
        end
      end
    end

    # Helper method returns true if and only if the response from the API call was
    # successful
    #
    # ==== Returns:
    #
    # true on success; false otherwise
    #
    def ok?
      if @http_raw_response.kind_of? Net::HTTPNoContent
        #if there is no content expected, use HTTP code
        204 == @http_status_code
      else
        # otherwise use API status
        @http_raw_response.kind_of? Net::HTTPOK and 0 == @api_status.to_i
      end
    end


    # DEPRECATED
    # Getter method for deprecated 'json' member variable.
    def json
      @body
    end

    # DEPRECATED
    # Getter method for deprecated 'original_request' member variable.
    def original_request
      @request
    end
  end

  # This class wraps accesses through the API
  #
  class Client
    API_ENDPOINT = ENV["SIFT_RUBY_API_URL"] || 'https://api.siftscience.com'
    API3_ENDPOINT = ENV["SIFT_RUBY_API3_URL"] || 'https://api3.siftscience.com'

    include HTTParty
    base_uri API_ENDPOINT

    attr_reader :api_key, :account_id

    def self.build_auth_header(api_key)
      { "Authorization" => "Basic #{Base64.encode64(api_key)}" }
    end

    def self.user_agent
      "sift-ruby/#{VERSION}"
    end

    # Constructor
    #
    # ==== Parameters:
    #
    # opts (optional)::
    #   A Hash of optional parameters for this Client --
    #
    #   :api_key::
    #     The Sift Science API key associated with your account.
    #     Sift.api_key is used if this parameter is not set.
    #
    #   :account_id::
    #     The ID of your Sift Science account.  Sift.account_id is
    #     used if this parameter is not set.
    #
    #   :timeout::
    #     The number of seconds to wait before failing a request. By
    #     default this is configured to 2 seconds.
    #
    #   :version::
    #     The version of the Events API, Score API, and Labels API to call.
    #     By default, version 205.
    #
    #   :path::
    #     The URL path to use for Events API path.  By default, the
    #     official path of the specified-version of the Events API.
    #
    #
    def initialize(opts = {})
      @api_key = opts[:api_key] || Sift.api_key
      @account_id = opts[:account_id] || Sift.account_id
      @version = opts[:version] || API_VERSION
      @timeout = opts[:timeout] || 2  # 2-second timeout by default
      @path = opts[:path] || Sift.rest_api_path(@version)

      raise("api_key") if !@api_key.is_a?(String) || @api_key.empty?
      raise("path must be a non-empty string") if !@path.is_a?(String) || @path.empty?
    end

    def user_agent
      "SiftScience/v#{@version} sift-ruby/#{VERSION}"
    end


    # Sends an event to the Sift Science Events API.
    #
    # See https://siftscience.com/developers/docs/ruby/events-api .
    #
    # ==== Parameters:
    #
    # event::
    #   The name of the event to send. This can be either a reserved
    #   event name, like $transaction or $label or a custom event name
    #   (that does not start with a $).  This parameter must be
    #   specified.
    #
    # properties::
    #   A hash of name-value pairs that specify the event-specific
    #   attributes to track.  This parameter must be specified.
    #
    # opts (optional)::
    #   A Hash of optional parameters for the request --
    #
    #   :return_score::
    #     If true, requests that the response include a score for this
    #     user, computed using the submitted event.  See
    #     https://siftscience.com/developers/docs/ruby/score-api/synchronous-scores
    #
    #   :abuse_types::
    #     List of abuse types, specifying for which abuse types a
    #     score should be returned (if scoring was requested).  By
    #     default, a score is returned for every abuse type to which
    #     you are subscribed.
    #
    #   :return_action::
    #     If true, requests that the response include any actions
    #     triggered as a result of the tracked event.
    #
    #   :return_workflow_status::
    #     If true, requests that the response include the status of
    #     any workflow run as a result of the tracked event.  See
    #     https://siftscience.com/developers/docs/ruby/workflows-api/workflow-decisions
    #
    #   :timeout::
    #     Overrides the timeout (in seconds) for this call.
    #
    #   :api_key::
    #     Overrides the API key for this call.
    #
    #   :version::
    #     Overrides the version of the Events API to call.
    #
    #   :path::
    #     Overrides the URI path for this API call.
    #
    # ==== Returns:
    #
    # In the case of a connection error (timeout, broken connection,
    # etc.), this method returns nil; otherwise, a Response object is
    # returned that captures the status message and status code.
    #
    def track(event, properties = {}, opts = {})
      api_key = opts[:api_key] || @api_key
      version = opts[:version] || @version
      path = opts[:path] || (version && Sift.rest_api_path(version)) || @path
      timeout = opts[:timeout] || @timeout
      return_score = opts[:return_score]
      return_action = opts[:return_action]
      return_workflow_status = opts[:return_workflow_status]
      force_workflow_run = opts[:force_workflow_run]
      abuse_types = opts[:abuse_types]

      raise("event must be a non-empty string") if (!event.is_a? String) || event.empty?
      raise("properties cannot be empty") if properties.empty?
      raise("api_key cannot be empty") if api_key.empty?

      query = {}
      query["return_score"] = "true" if return_score
      query["return_action"] = "true" if return_action
      query["return_workflow_status"] = "true" if return_workflow_status
      query["force_workflow_run"] = "true" if force_workflow_run
      query["abuse_types"] = abuse_types.join(",") if abuse_types

      options = {
        :body => MultiJson.dump(delete_nils(properties).merge({"$type" => event,
                                                               "$api_key" => api_key})),
        :headers => {"User-Agent" => user_agent},
        :query => query
      }
      options.merge!(:timeout => timeout) unless timeout.nil?

      begin
        response = self.class.post(path, options)
        Response.new(response.body, response.code, response.response)
      rescue StandardError => e
        Sift.warn("Failed to track event: " + e.to_s)
        Sift.warn(e.backtrace)
        nil
      end
    end


    # Retrieves a user's fraud score from the Sift Science API.
    #
    # See https://siftscience.com/developers/docs/ruby/score-api/score-api .
    #
    # ==== Parameters:
    #
    # user_id::
    #   A user's id. This id should be the same as the user_id used in
    #   event calls.
    #
    # opts (optional)::
    #   A Hash of optional parameters for the request --
    #
    #   :abuse_types::
    #     List of abuse types, specifying for which abuse types a
    #     score should be returned.  By default, a score is returned
    #     for every abuse type to which you are subscribed.
    #
    #   :api_key::
    #     Overrides the API key for this call.
    #
    #   :timeout::
    #     Overrides the timeout (in seconds) for this call.
    #
    #   :version::
    #     Overrides the version of the Events API to call.
    #
    # ==== Returns:
    #
    # A Response object containing a status code, status message, and,
    # if successful, the user's score(s).
    #
    def score(user_id, opts = {})
      abuse_types = opts[:abuse_types]
      api_key = opts[:api_key] || @api_key
      timeout = opts[:timeout] || @timeout
      version = opts[:version] || @version

      raise("user_id must be a non-empty string") if (!user_id.is_a? String) || user_id.to_s.empty?
      raise("Bad api_key parameter") if api_key.empty?

      query = {}
      query["api_key"] = api_key
      query["abuse_types"] = abuse_types.join(",") if abuse_types

      options = {
        :headers => {"User-Agent" => user_agent},
        :query => query
      }
      options.merge!(:timeout => timeout) unless timeout.nil?

      response = self.class.get(Sift.score_api_path(user_id, version), options)
      Response.new(response.body, response.code, response.response)
    end


    # Labels a user.
    #
    # See https://siftscience.com/developers/docs/ruby/labels-api/label-user .
    #
    # ==== Parameters:
    #
    # user_id::
    #   A user's id. This id should be the same as the user_id used in
    #   event calls.
    #
    # properties::
    #   A hash of name-value pairs that specify the label attributes.
    #   This parameter must be specified.
    #
    # opts (optional)::
    #   A Hash of optional parameters for the request --
    #
    #   :api_key::
    #     Overrides the API key for this call.
    #
    #   :timeout::
    #     Overrides the timeout (in seconds) for this call.
    #
    #   :version::
    #     Overrides the version of the Events API to call.
    #
    # ==== Returns:
    #
    # In the case of a connection error (timeout, broken connection,
    # etc.), this method returns nil; otherwise, a Response object is
    # returned that captures the status message and status code.
    #
    def label(user_id, properties = {}, opts = {})
      api_key = opts[:api_key] || @api_key
      timeout = opts[:timeout] || @timeout
      version = opts[:version] || @version
      path = Sift.users_label_api_path(user_id, version)

      raise("user_id must be a non-empty string") if (!user_id.is_a? String) || user_id.to_s.empty?

      track("$label", delete_nils(properties),
            :path => path, :api_key => api_key, :timeout => timeout)
    end


    # Unlabels a user.
    #
    # See https://siftscience.com/developers/docs/ruby/labels-api/unlabel-user .
    #
    # ==== Parameters:
    #
    # user_id::
    #   A user's id. This id should be the same as the user_id used in
    #   event calls.
    #
    # opts (optional)::
    #   A Hash of optional parameters for this request --
    #
    #   :abuse_type::
    #     The abuse type for which the user should be unlabeled.  If
    #     omitted, the user is unlabeled for all abuse types.
    #
    #   :api_key::
    #     Overrides the API key for this call.
    #
    #   :timeout::
    #     Overrides the timeout (in seconds) for this call.
    #
    #   :version::
    #     Overrides the version of the Events API to call.
    #
    # ==== Returns:
    #
    # A Response object is returned with only an http code of 204.
    #
    def unlabel(user_id, opts = {})
      abuse_type = opts[:abuse_type]
      api_key = opts[:api_key] || @api_key
      timeout = opts[:timeout] || @timeout
      version = opts[:version] || @version

      raise("user_id must be a non-empty string") if (!user_id.is_a? String) || user_id.to_s.empty?

      query = {}
      query[:api_key] = api_key
      query[:abuse_type] = abuse_type if abuse_type

      options = {
        :headers => {},
        :query => query
      }
      options.merge!(:timeout => timeout) unless timeout.nil?

      response = self.class.delete(Sift.users_label_api_path(user_id, version), options)
      Response.new(response.body, response.code, response.response)
    end


    # Gets the status of a workflow run.
    #
    # See https://siftscience.com/developers/docs/ruby/workflows-api/workflow-status .
    #
    # ==== Parameters
    #
    # run_id::
    #   The ID of a workflow run.
    #
    # opts (optional)::
    #   A Hash of optional parameters for this request --
    #
    #   :account_id::
    #     Overrides the API key for this call.
    #
    #   :api_key::
    #     Overrides the API key for this call.
    #
    #   :timeout::
    #     Overrides the timeout (in seconds) for this call.
    #
    def get_workflow_status(run_id, opts = {})
      account_id = opts[:account_id] || @account_id
      api_key = opts[:api_key] || @api_key
      timeout = opts[:timeout] || @timeout

      options = {
        :headers => { "User-Agent" => user_agent },
        :basic_auth => { :username => api_key, :password => "" }
      }
      options.merge!(:timeout => timeout) unless timeout.nil?

      uri = API3_ENDPOINT + Sift.workflow_status_path(account_id, run_id)
      response = self.class.get(uri, options)
      Response.new(response.body, response.code, response.response)
    end


    # Gets the decision status of a user.
    #
    # See https://siftscience.com/developers/docs/ruby/decisions-api/decision-status .
    #
    # ==== Parameters
    #
    # user_id::
    #   The ID of user.
    #
    # opts (optional)::
    #   A Hash of optional parameters for this request --
    #
    #   :account_id::
    #     Overrides the API key for this call.
    #
    #   :api_key::
    #     Overrides the API key for this call.
    #
    #   :timeout::
    #     Overrides the timeout (in seconds) for this call.
    #
    def get_user_decisions(user_id, opts = {})
      account_id = opts[:account_id] || @account_id
      api_key = opts[:api_key] || @api_key
      timeout = opts[:timeout] || @timeout

      options = {
        :headers => { "User-Agent" => user_agent },
        :basic_auth => { :username => api_key, :password => "" }
      }
      options.merge!(:timeout => timeout) unless timeout.nil?

      uri = API3_ENDPOINT + Sift.user_decisions_api_path(account_id, user_id)
      response = self.class.get(uri, options)
      Response.new(response.body, response.code, response.response)
    end


    # Gets the decision status of an order.
    #
    # See https://siftscience.com/developers/docs/ruby/decisions-api/decision-status .
    #
    # ==== Parameters
    #
    # order_id::
    #   The ID of an order.
    #
    # opts (optional)::
    #   A Hash of optional parameters for this request --
    #
    #   :account_id::
    #     Overrides the API key for this call.
    #
    #   :api_key::
    #     Overrides the API key for this call.
    #
    #   :timeout::
    #     Overrides the timeout (in seconds) for this call.
    #
    def get_order_decisions(order_id, opts = {})
      account_id = opts[:account_id] || @account_id
      api_key = opts[:api_key] || @api_key
      timeout = opts[:timeout] || @timeout

      options = {
        :headers => { "User-Agent" => user_agent },
        :basic_auth => { :username => api_key, :password => "" }
      }
      options.merge!(:timeout => timeout) unless timeout.nil?

      uri = API3_ENDPOINT + Sift.order_decisions_api_path(account_id, order_id)
      response = self.class.get(uri, options)
      Response.new(response.body, response.code, response.response)
    end

    # Gets the decision status of a session.
    #
    # See https://siftscience.com/developers/docs/ruby/decisions-api/decision-status .
    #
    # ==== Parameters
    #
    # user_id::
    #   The ID of the user in the session.
    #
    # session_id::
    #   The ID of a session.
    #
    # opts (optional)::
    #   A Hash of optional parameters for this request --
    #
    #   :account_id::
    #     Overrides the account id for this call.
    #
    #   :api_key::
    #     Overrides the API key for this call.
    #
    #   :timeout::
    #     Overrides the timeout (in seconds) for this call.
    #
    def get_session_decisions(user_id, session_id, opts = {})
      account_id = opts[:account_id] || @account_id
      api_key = opts[:api_key] || @api_key
      timeout = opts[:timeout] || @timeout

      options = {
        :headers => { "User-Agent" => user_agent },
        :basic_auth => { :username => api_key, :password => "" }
      }
      options.merge!(:timeout => timeout) unless timeout.nil?

      uri = API3_ENDPOINT + Sift.session_decisions_api_path(account_id, user_id, session_id)
      response = self.class.get(uri, options)
      Response.new(response.body, response.code, response.response)
    end

    # Gets the decision status of a piece of content.
    #
    # See https://siftscience.com/developers/docs/ruby/decisions-api/decision-status .
    #
    # ==== Parameters
    #
    # user_id::
    #   The ID of the owner of the content.
    #
    # content_id::
    #   The ID of a piece of content.
    #
    # opts (optional)::
    #   A Hash of optional parameters for this request --
    #
    #   :account_id::
    #     Overrides the API key for this call.
    #
    #   :api_key::
    #     Overrides the API key for this call.
    #
    #   :timeout::
    #     Overrides the timeout (in seconds) for this call.
    #
    def get_content_decisions(user_id, content_id, opts = {})
      account_id = opts[:account_id] || @account_id
      api_key = opts[:api_key] || @api_key
      timeout = opts[:timeout] || @timeout

      options = {
        :headers => { "User-Agent" => user_agent },
        :basic_auth => { :username => api_key, :password => "" }
      }
      options.merge!(:timeout => timeout) unless timeout.nil?

      uri = API3_ENDPOINT + Sift.content_decisions_api_path(account_id, user_id, content_id)
      response = self.class.get(uri, options)
      Response.new(response.body, response.code, response.response)
    end

    def decisions(opts = {})
      decision_instance.list(opts)
    end

    def decisions!(opts = {})
      handle_response(decisions(opts))
    end

    def apply_decision(configs = {})
      decision_instance.apply_to(configs)
    end

    def apply_decision!(configs = {})
      handle_response(apply_decision(configs))
    end

    private

    def handle_response(response)
      if response.ok?
        response.body
      else
        raise ApiError.new(response.api_error_message, response)
      end
    end

    def decision_instance
      @decision_instance ||= Decision.new(api_key, account_id)
    end

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
