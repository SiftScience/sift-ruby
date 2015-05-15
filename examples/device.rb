#!/usr/bin/env ruby
#
# A simple example of how to use the API.

require 'rubygems'
require 'sift'
require 'multi_json'

TIMEOUT = 5 
api_key = ENV['API_KEY']
account_id = ENV['ACCOUNT_ID']


if api_key.nil? || account_id.nil?
  puts "Please specify the environment variables API_KEY and API_ID"
  puts "usage:"
  puts " API_KEY=xxxxxx API_ID=xxxxxxxx ruby device_id.rb"
  puts
  exit
end

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
Sift.api_key = api_key
Sift.account_id = account_id

def print_device(d)
  puts 'i got the device obj: ' + d.inspect
  puts 'device bad? ' + d.bad?.to_s
  puts 'device labeled? ' + d.labeled?.to_s
  puts 'device labeled_at ' + d.labeled_at.to_s
  puts 'device session timestamps ' + d.session_timestamps.join(',')
end

device = Sift::Device.retrieve("i08a78q46cekukrugj7ltnqskj")
if device
  print_device(device)
end

session = Sift::Session.retrieve("session_id")
if session
  print_device(session.device)
  current_label = session.device.label_bad!

  puts 'got label from API result: ' + current_label.to_s
  puts 'session device label ' + session.device.label

end

exit 0
