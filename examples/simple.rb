#!/usr/bin/env ruby
#
# A simple example of how to use the API.

require 'rubygems'
require 'sift'
require 'multi_json'

TIMEOUT = 5

if ARGV.length.zero?
  puts "Please specify an API key"
  puts "usage:"
  puts " ruby simple <API KEY>"
  puts
  exit
end
api_key = ARGV[0];

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

def handle_response(response)
  if response.nil?
    puts 'Error: there was an HTTP error calling through the API'
  else
    puts 'Successfully sent request; was ok? : ' + response.ok?.to_s
    puts 'API error message                  : ' + response.api_error_message.to_s
    puts 'API status code                    : ' + response.api_status.to_s
    puts 'HTTP status code                   : ' + response.http_status_code.to_s
    puts 'original request                   : ' + response.original_request.to_s
  end
end

Sift.logger = MyLogger.new

client = Sift::Client.new(api_key)
user_id = "3"
event = "my_custom_event"
properties = {
  "my_custom_field1" => "my custom value 1",
  "my_custom_field2" => "my custom value 2",
  "$user_id" => user_id,
  "$time" => Time.now.to_i,
}

handle_response client.track(event, properties, TIMEOUT)
handle_response client.label(user_id, {"$is_bad" => true, "$reasons" => ["$chargeback", "$span"], "$description" => "free form text here" }, TIMEOUT)

