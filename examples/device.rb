#!/usr/bin/env ruby
#
# A simple example of how to use the API.

require 'rubygems'
require 'sift'
require 'multi_json'
require 'logger'

TIMEOUT = 5
api_key = ENV['API_KEY']
account_id = ENV['ACCOUNT_ID']

if api_key.nil? || account_id.nil?
  puts "Please specify the environment variables API_KEY and ACCOUNT_ID"
  puts "usage:"
  puts " API_KEY=xxxxxx ACCOUNT_ID=xxxxxxxx ruby device_id.rb"
  puts
  exit 1
end

Sift.logger = Logger.new(STDERR)
Sift.api_key = api_key
Sift.account_id = account_id

begin
  device_id = ENV['DEVICE_ID']
  session_id = ENV['SESSION_ID']

  device =
    if device_id
      Sift::Device.retrieve(device_id)
    elsif session_id
      session = Sift::Session.retrieve(session_id)
      if session
        session.device
      end
    else
      raise("Must provide one of DEVICE_ID or SESSION_ID")
    end

  if device
    puts "device obj: #{device}"
    puts "first_seen: #{device.first_seen}"
    puts "device bad? #{device.bad?}"
    puts "device labeled? #{device.labeled?}"
    puts "device labeled_at #{device.labeled_at.to_s}"
    puts
    puts "Visit times: #{device.sessions.data.map{|x| x.time.to_s}.join(", ")}"
    puts
    puts "network first seen time: #{device.network.first_seen}"
    puts "device score: #{device.network.score}"
    puts
    print "Label [bad|not_bad]> "
    case gets.strip
    when "bad"
      puts "device #{device.id} now #{device.label_bad!}"
    when "not_bad"
      puts "device #{device.id} now #{device.label_not_bad!}"
    else
      $stderr.puts "invalid label; options are 'bad' and 'not_bad'"
    end
  else
    raise("Device not found")
  end
rescue Sift::HttpRequestError => e
  $stderr.puts e.http_status
  $stderr.puts e.body
  $stderr.puts $!
end

exit 0
