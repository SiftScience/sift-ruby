require "sift"
require 'multi_json'

#$api_key = "put-a-valid-apikey"
#$user_id = "put-a-valid-userid"

def valid_send_properties
    {
      :$user_id => $user_id,
	  :$send_to => $user_id,
      :$verification_type => '$email',
      :$brand_name => 'all',
      :$language => 'en',
      :$event => {
                :$session_id => 'gigtleqddo84l8cm15qe4il',
                :$verified_event => '$login',
                :$reason => '$automated_rule',
                :$ip => '192.168.1.1',
                :$browser => {
                    :$user_agent => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36'
                }
            }
    }
end

def valid_resend_properties
    {
      :$user_id => $user_id,
      :$verified_event => '$login'
    }
end

def valid_check_properties
    {
      :$user_id => $user_id,
      :$code => '668316'
    }
end

  #response = Sift::Client.new(:api_key => $api_key,:user_id => $user_id,:version=>1.1).verification_send(valid_send_properties)

  #response = Sift::Client.new(:api_key => $api_key,:user_id => $user_id,:version=>1.1).verification_resend(valid_resend_properties)
  response = Sift::Client.new(:api_key => $api_key,:user_id => $user_id,:version=>1.1).verification_check(valid_check_properties)

  p response

  puts "completed"
