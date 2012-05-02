require 'httparty'

module Sift
  class Client

    include HTTParty

    base_uri "https://api.siftscience.com"
    default_timeout 2

    STATUS = "status"
    MESSAGE = "message"

    # Upon instantiation, receive the API key for communicating with the
    # REST API
    def initialize(api_key)
      @api_key = api_key
      raise "api_key is required" if @api_key.nil?
    end

    # A simple function for asynchronously logging to the Sift Science API.
    #
    # event: The overall event/category you would like to log this data under
    # properties: A hash of key-value pairs that describe metadata around
    # the event. This must include the API key as ‘api_key’ and the user id
    # for which this event was emitted as ‘user_id’
    #
    # See http://siftscience.com/api/ for further detail.
    def track(event, properties = {})

      params = properties.merge({"$type" => event, "$api_key" => @api_key})

      puts 'before send'
      response = self.class.post(SiftScience.current_rest_api_path, params)

      if response.code != Net::HTTPOK

      end

      puts 'after send'
      puts result.inspect


    rescue Exception => e
      # Log the failure, but don’t propagate the error
      puts "Failed to log event: " + e.message
    end
  end

end
