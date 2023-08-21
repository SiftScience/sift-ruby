require 'rubygems'
require 'sift'
require 'multi_json'

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
    puts 'response body                      : ' + response.body.to_s
  end
end

Sift.logger = MyLogger.new

$api_key = 'put-valid-api-key'
$account_id = 'put-valid-account-id'

def post_merchant_properties
  # Sample psp_merchant_profile
  {
    "id": "merchant_id_01004",
    "name": "Wonderful Payments Inc.",
    "description": "Wonderful Payments payment provider.",
    "address": {
      "name": "Alany",
      "address_1": "Big Payment blvd, 22",
      "address_2": "apt, 8",
      "city": "New Orleans",
      "region": "NA",
      "country": "US",
      "zipcode": "76830",
      "phone": "0394888320"
    },
    "category": "1002",
    "service_level": "Platinum",
    "status": "active",
    "risk_profile": {
      "level": "low",
      "score": 10
    }
  }
end

def put_merchant_properties
  # Sample update psp_merchant_profile
  {
    "id": "merchant_id_01004",
    "name": "Wonderful Payments Inc. update",
    "description": "Wonderful Payments payment provider. update",
    "address": {
      "name": "Alany",
      "address_1": "Big Payment blvd, 22",
      "address_2": "apt, 8",
      "city": "New Orleans",
      "region": "NA",
      "country": "US",
      "zipcode": "76830",
      "phone": "0394888320"
    },
    "category": "1002",
    "service_level": "Platinum",
    "status": "active",
    "risk_profile": {
      "level": "low",
      "score": 10
    }
  }
end

# handle_response Sift::Client.new(:api_key => $api_key, :account_id => $account_id).create_psp_merchant_profile(post_merchant_properties)

# handle_response Sift::Client.new(:api_key => $api_key, :account_id => $account_id).update_psp_merchant_profile("merchant_id_01004", put_merchant_properties)

# handle_response Sift::Client.new(:api_key => $api_key, :account_id => $account_id).get_a_psp_merchant_profile("merchant_id_01004")

# handle_response Sift::Client.new(:api_key => $api_key, :account_id => $account_id).get_psp_merchant_profiles()

# handle_response Sift::Client.new(:api_key => $api_key, :account_id => $account_id).get_psp_merchant_profiles(2)

handle_response Sift::Client.new(:api_key => $api_key, :account_id => $account_id).get_psp_merchant_profiles(5, "next_ref")

puts "request completed"
