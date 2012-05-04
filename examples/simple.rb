#!/usr/bin/env ruby
#
# A simple example of how to use the API.

require 'rubygems'
require 'sift'
require 'multi_json'

api_key = "" # TODO: Set your API key here

class MyLogger
  def warn(e)
    puts "[WARN]  " + e.to_s
  end

  def error(e)
    puts "[ERROR] " + e.to_s
  end

  def fatal(e)
    puts "[FATAL] " + e.to_s
  end

  def info(e)
    puts "[INFO]  " + e.to_s
  end
end

Sift.logger = MyLogger.new

client = Sift::Client.new(api_key)
event = "my_custom_event"
properties = {
  "my_custom_field1" => "my custom value 1",
  "my_custom_field2" => "my custom value 2",
  "$user_id" => "3",
  "$time" => Time.now.to_i,
}

response = client.track(event, properties)
if response.nil?
  puts 'Error: there was an HTTP error calling through the API'
else
  puts 'Successfully sent request; was ok? : ' + response.ok?.to_s
  puts 'API error message                  : ' + response.api_error_message.to_s
  puts 'API status code                    : ' + response.api_status.to_s
  puts 'HTTP status code                   : ' + response.http_status_code.to_s
  puts 'original request                   : ' + response.original_request.to_s
end

