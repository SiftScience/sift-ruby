require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe Sift do

  it "test action response" do
    Sift.api_key = 'd86ef3777aa34729'
    client = Sift::Client.new()

    # send a transaction event -- note this is blocking 
    event = "$transaction"

    user_id = "23056" # User ID's may only contain a-z, A-Z, 0-9, =, ., -, _, +, @, :, &, ^, %, !, $

    properties = {
     "$user_id" => user_id, 
     "$user_email" => "buyer@gmail.com", 
     "$seller_user_id" => "2371", 
     "seller_user_email" => "seller@gmail.com", 
     "$transaction_id" => "573050", 
     "$payment_method" => {
      "$payment_type"    => "$credit_card",
      "$payment_gateway" => "$braintree",
      "$card_bin"        => "542486",
      "$card_last4"      => "4444"             
      },
      "$currency_code" => "USD",
      "$amount" => 15230000,
    }

    response = client.track(event, properties, nil, nil, true)
    puts response.inspect
  end

  it "test score response" do
    Sift.api_key = 'd86ef3777aa34729'
    client = Sift::Client.new()

    # send a transaction event -- note this is blocking 
    event = "$transaction"

    user_id = "23056" # User ID's may only contain a-z, A-Z, 0-9, =, ., -, _, +, @, :, &, ^, %, !, $

    properties = {
     "$user_id" => user_id, 
     "$user_email" => "buyer@gmail.com", 
     "$seller_user_id" => "2371", 
     "seller_user_email" => "seller@gmail.com", 
     "$transaction_id" => "573050", 
     "$payment_method" => {
      "$payment_type"    => "$credit_card",
      "$payment_gateway" => "$braintree",
      "$card_bin"        => "542486",
      "$card_last4"      => "4444"             
      },
      "$currency_code" => "USD",
      "$amount" => 15230000,
    }

    response = client.track(event, properties, nil, nil, nil, true)
    puts response.inspect
  end

end
