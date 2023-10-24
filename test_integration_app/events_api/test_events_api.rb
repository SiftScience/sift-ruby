require "sift"

class EventsAPI

    @@client = Sift::Client.new(:api_key => ENV["api_key"])
    
    def login()
    
      # Sample $login event
        properties = {
            # Required Fields
            "$user_id"      => $user_id,
            "$login_status" => "$failure",
        
            "$session_id" => "gigtleqddo84l8cm15qe4il",
            "$ip"         => "128.148.1.135",
        
            # Optional Fields
            "$user_email"     => $user_email,
            "$failure_reason" => "$account_unknown",
            "$username"       => "billjones1@example.com",
            "$account_types"  => ["merchant", "premium"],
            "$social_sign_on_type"  => "$linkedin",
            "$brand_name"   => "sift",
            "$site_domain"  => "sift.com",
            "$site_country" => "US",
        
            # Send this information with a login from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }

        return @@client.track("$login", properties)
    end
    
    def transaction()
    
        # Sample $transaction event
        properties = {
            # Required Fields
            "$user_id"          => $user_id,
            "$amount"           => 506790000, # $506.79
            "$currency_code"    => "USD",
        
            # Supported Fields
            "$user_email"       => $user_email,
            "$transaction_type" => "$sale",
            "$transaction_status" => "$failure",
            "$decline_category" => "$bank_decline",
            "$order_id"         => "ORDER-123124124",
            "$transaction_id"   => "719637215",
        
            "$billing_address"  => { # or "$sent_address" # or "$received_address"
                "$name"         => "Bill Jones",
                "$phone"        => "1-415-555-6041",
                "$address_1"    => "2100 Main Street",
                "$address_2"    => "Apt 3B",
                "$city"         => "New London",
                "$region"       => "New Hampshire",
                "$country"      => "US",
                "$zipcode"      => "03257"
            },
            "$brand_name"   => "sift",
            "$site_domain"  => "sift.com",
            "$site_country" => "US",
            "$ordered_from" => {
                "$store_id"      => "123",
                "$store_address" => {
                    "$name"       => "Bill Jones",
                    "$phone"      => "1-415-555-6040",
                    "$address_1"  => "2100 Main Street",
                    "$address_2"  => "Apt 3B",
                    "$city"       => "New London",
                    "$region"     => "New Hampshire",
                    "$country"    => "US",
                    "$zipcode"    => "03257"
                }
            },
            # Credit card example
            "$payment_method"   => {
                "$payment_type"    => "$credit_card",
                "$payment_gateway" => "$braintree",
                "$card_bin"        => "542486",
                "$card_last4"      => "4444"
            },
        
            # Supported fields for 3DS
            "$status_3ds"                     => "$attempted",
            "$triggered_3ds"                  => "$processor",
            "$merchant_initiated_transaction" => false,
        
            # Supported Fields
            "$shipping_address" => {
                "$name"         => "Bill Jones",
                "$phone"        => "1-415-555-6041",
                "$address_1"    => "2100 Main Street",
                "$address_2"    => "Apt 3B",
                "$city"         => "New London",
                "$region"       => "New Hampshire",
                "$country"      => "US",
                "$zipcode"      => "03257"
            },
            "$session_id"       => "gigtleqddo84l8cm15qe4il",
        
            # For marketplaces, use $seller_user_id to identify the seller
            "$seller_user_id"     => "slinkys_emporium",
        
            # Sample Custom Fields
            "digital_wallet"      => "apple_pay", # "google_wallet", etc.
            "coupon_code"         => "dollarMadness",
            "shipping_choice"     => "FedEx Ground Courier",
            "is_first_time_buyer" => false,
        
            # Send this information from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }
        
        return @@client.track("$transaction", properties)
    end
    
    def create_order()
    
      # Sample $create_order event
        properties = {
            # Required Fields
            "$user_id"          => $user_id,
            # Supported Fields
            "$session_id"       => "gigtleqddo84l8cm15qe4il",
            "$order_id"         => "ORDER-28168441",
            "$user_email"       => $user_email,
            "$amount"           => 115940000, # $115.94
            "$currency_code"    => "USD",
            "$billing_address"  => {
                "$name"         => "Bill Jones",
                "$phone"        => "1-415-555-6041",
                "$address_1"    => "2100 Main Street",
                "$address_2"    => "Apt 3B",
                "$city"         => "New London",
                "$region"       => "New Hampshire",
                "$country"      => "US",
                "$zipcode"      => "03257"
            },
            "$payment_methods"  => [
                {
                    "$payment_type"    => "$credit_card",
                    "$payment_gateway" => "$braintree",
                    "$card_bin"        => "542486",
                    "$card_last4"      => "4444"
                }
            ],
            "$ordered_from" => {
                "$store_id"      => "123",
                "$store_address" => {
                    "$name"       => "Bill Jones",
                    "$phone"      => "1-415-555-6040",
                    "$address_1"  => "2100 Main Street",
                    "$address_2"  => "Apt 3B",
                    "$city"       => "New London",
                    "$region"     => "New Hampshire",
                    "$country"    => "US",
                    "$zipcode"    => "03257"
                }
            },
            "$brand_name"   => "sift",
            "$site_domain"  => "sift.com",
            "$site_country" => "US",
            "$shipping_address"  => {
                "$name"          => "Bill Jones",
                "$phone"         => "1-415-555-6041",
                "$address_1"     => "2100 Main Street",
                "$address_2"     => "Apt 3B",
                "$city"          => "New London",
                "$region"        => "New Hampshire",
                "$country"       => "US",
                "$zipcode"       => "03257"
            },
            "$expedited_shipping"       => true,
            "$shipping_method"          => "$physical",
            "$shipping_carrier"         => "UPS",
            "$shipping_tracking_numbers"=> ["1Z204E380338943508", "1Z204E380338943509"],
            "$items"                    => [
                {
                    "$item_id"        => "12344321",
                    "$product_title"  => "Microwavable Kettle Corn: Original Flavor",
                    "$price"          => 4990000, # $4.99
                    "$upc"            => "097564307560",
                    "$sku"            => "03586005",
                    "$brand"          => "Peters Kettle Corn",
                    "$manufacturer"   => "Peters Kettle Corn",
                    "$category"       => "Food and Grocery",
                    "$tags"           => ["Popcorn", "Snacks", "On Sale"],
                    "$quantity"       => 4
                },
                {
                    "$item_id"        => "B004834GQO",
                    "$product_title"  => "The Slanket Blanket-Texas Tea",
                    "$price"          => 39990000, # $39.99
                    "$upc"            => "6786211451001",
                    "$sku"            => "004834GQ",
                    "$brand"          => "Slanket",
                    "$manufacturer"   => "Slanket",
                    "$category"       => "Blankets & Throws",
                    "$tags"           => ["Awesome", "Wintertime specials"],
                    "$color"          => "Texas Tea",
                    "$quantity"       => 2
                }
            ],
            # For marketplaces, use $seller_user_id to identify the seller
            "$seller_user_id"     => "slinkys_emporium",
        
            "$promotions"         => [
                {
                    "$promotion_id" => "FirstTimeBuyer",
                    "$status"       => "$success",
                    "$description"  => "$5 off",
                    "$discount"     => {
                        "$amount"                   => 5000000,  # $5.00
                        "$currency_code"            => "USD",
                        "$minimum_purchase_amount"  => 25000000  # $25.00
                    }
                }
            ],
        
            # Sample Custom Fields
            "digital_wallet"      => "apple_pay", # "google_wallet", etc.
            "coupon_code"         => "dollarMadness",
            "shipping_choice"     => "FedEx Ground Courier",
            "is_first_time_buyer" => false,
        
            # Send this information from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }
        
        return @@client.track("$create_order", properties)
    end
    
    def create_content()
    
       # Sample $create_content event for comments
        comment_properties = {
            # Required fields
            '$user_id'              => $user_id,
            '$content_id'           => 'comment-23412',
        
            # Recommended fields
            '$session_id'           => 'a234ksjfgn435sfg',
            '$status'               => '$active',
            '$ip'                   => '255.255.255.0',
        
            # Required $comment object
            '$comment'              => {
                '$body'               => 'Congrats on the new role!',
                '$contact_email'      => 'alex_301@domain.com',
                '$parent_comment_id'  => 'comment-23407',
                '$root_content_id'    => 'listing-12923213',
                '$images'             => [
                    {
                        '$md5_hash'            => '0cc175b9c0f1b6a831c399e269772661',
                        '$link'                => 'https://www.domain.com/file.png',
                        '$description'         => 'An old picture'
                    }
                ]
            },
        
            # Send this information from an APP client.
            "$app"        => {
                # Example for the iOS Calculator app.
                "$os"                  => "iOS",
                "$os_version"          => "10.1.3",
                "$device_manufacturer" => "Apple",
                "$device_model"        => "iPhone 4,2",
                "$device_unique_id"    => "A3D261E4-DE0A-470B-9E4A-720F3D3D22E6",
                "$app_name"            => "Calculator",
                "$app_version"         => "3.2.7",
                "$client_language"     => "en-US"
            }
        }
        
        return @@client.track("$create_content", comment_properties)
    end
    
    def create_content_listing()
    
       # Sample $create_content event for listings
        listing_properties = {
            # Required fields
            '$user_id'            => $user_id,
            '$content_id'         => 'listing-23412',
        
            # Recommended fields
            '$session_id'         => 'a234ksjfgn435sfg',
            '$status'             => '$active',
            '$ip'                 => '255.255.255.0',
        
            # Required $listing object
            '$listing'            => {
                '$subject'          => '2 Bedroom Apartment for Rent',
                '$body'             => 'Capitol Hill Seattle brand new condo. 2 bedrooms and 1 full bath.',
                '$contact_email'    => 'alex_301@domain.com',
                '$contact_address'  => {
                    '$name'           => 'Bill Jones',
                    '$phone'          => '1-415-555-6041',
                    '$city'           => 'New London',
                    '$region'         => 'New Hampshire',
                    '$country'        => 'US',
                    '$zipcode'        => '03257'
                },
                '$locations'        => [
                    {
                        '$city'              => 'Seattle',
                        '$region'            => 'Washington',
                        '$country'           => 'US',
                        '$zipcode'           => '98112'
                    }
                ],
                '$listed_items'     => [
                    {
                        '$price'             => 2950000000, # $2950.00
                        '$currency_code'     => 'USD',
                        '$tags'              => ['heat', 'washer/dryer']
                    }
                ],
                '$images'           => [
                    {
                        '$md5_hash'          => '0cc175b9c0f1b6a831c399e269772661',
                        '$link'              => 'https://www.domain.com/file.png',
                        '$description'       => 'Billy’s picture'
                    }
                ],
                '$expiration_time'       => 1549063157000 # UNIX timestamp in milliseconds
            },
        
            # Send this information from an APP client.
            "$app"        => {
                # Example for the iOS Calculator app.
                "$os"                  => "iOS",
                "$os_version"          => "10.1.3",
                "$device_manufacturer" => "Apple",
                "$device_model"        => "iPhone 4,2",
                "$device_unique_id"    => "A3D261E4-DE0A-470B-9E4A-720F3D3D22E6",
                "$app_name"            => "Calculator",
                "$app_version"         => "3.2.7",
                "$client_language"     => "en-US"
            }
        }
        
        return @@client.track("$create_content", listing_properties)
    end
    
    def create_content_message()
    
       # Sample $create_content event for posts
        post_properties = {
            # Required fields
            '$user_id'            => $user_id,
            '$content_id'         => 'post-23412',
        
            # Recommended fields
            '$session_id'         => 'a234ksjfgn435sfg',
            '$status'             => '$active',
            '$ip'                 => '255.255.255.0',
        
            # Required $post object
            '$post'               => {
                '$subject'          => 'My new apartment!',
                '$body'             => 'Moved into my new apartment yesterday.',
                '$contact_email'    => 'alex_301@domain.com',
                '$contact_address'  => {
                    '$name'           => 'Bill Jones',
                    '$city'           => 'New London',
                    '$region'         => 'New Hampshire',
                    '$country'        => 'US',
                    '$zipcode'        => '03257'
                },
                '$locations'        => [
                    {
                        '$city'              => 'Seattle',
                        '$region'            => 'Washington',
                        '$country'           => 'US',
                        '$zipcode'           => '98112'
                    }
                ],
                '$categories'       => ['Personal'],
                '$images'           => [
                    {
                        '$md5_hash'          => '0cc175b9c0f1b6a831c399e269772661',
                        '$link'              => 'https://www.domain.com/file.png',
                        '$description'       => 'View from the window!'
                    }
                ],
                '$expiration_time'  => 1549063157000 # UNIX timestamp in milliseconds
            },
        
            # Send this information from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }
    
        return @@client.track("$create_content", post_properties)
    end
    
    def update_account()
    
        # Sample $update_account event
        properties = {
            # Required Fields
            "$user_id"    => $user_id,
        
            # Supported Fields
            "$changed_password" => true,
            "$user_email"       => $user_email,
            "$name"             => "Bill Jones",
            "$phone"            => "1-415-555-6040",
            "$referrer_user_id" => "janejane102",
            "$payment_methods"  => [
                {
                    "$payment_type"    => "$credit_card",
                    "$card_bin"        => "542486",
                    "$card_last4"      => "4444"
                }
            ],
            "$billing_address"  =>
            {
                "$name"         => "Bill Jones",
                "$phone"        => "1-415-555-6041",
                "$address_1"    => "2100 Main Street",
                "$address_2"    => "Apt 3B",
                "$city"         => "New London",
                "$region"       => "New Hampshire",
                "$country"      => "US",
                "$zipcode"      => "03257"
            },
            "$shipping_address" => {
                "$name"         => "Bill Jones",
                "$phone"        => "1-415-555-6041",
                "$address_1"    => "2100 Main Street",
                "$address_2"    => "Apt 3B",
                "$city"         => "New London",
                "$region"       => "New Hampshire",
                "$country"      => "US",
                "$zipcode"      => "03257"
            },
        
            "$social_sign_on_type"  => "$twitter",
            "$account_types"        => ["merchant", "premium"],
        
            # Send this information from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }
        
        return @@client.track("$update_account", properties)
    end
    
    def update_content_listing()
    
        # Sample $update_content event for listings
        listing_properties = {
            # Required fields
            '$user_id'            => $user_id,
            '$content_id'         => 'listing-23412',
        
            # Recommended fields
            '$session_id'         => 'a234ksjfgn435sfg',
            '$status'             => '$active',
            '$ip'                 => '255.255.255.0',
        
            # Required $listing object
            '$listing'            => {
                '$subject'          => '2 Bedroom Apartment for Rent',
                '$body'             => 'Capitol Hill Seattle brand new condo. 2 bedrooms and 1 full bath.',
                '$contact_email'    => 'alex_301@domain.com',
                '$contact_address'  => {
                    '$name'           => 'Bill Jones',
                    '$phone'          => '1-415-555-6041',
                    '$city'           => 'New London',
                    '$region'         => 'New Hampshire',
                    '$country'        => 'US',
                    '$zipcode'        => '03257'
                },
                '$locations'        => [
                    {
                        '$city'              => 'Seattle',
                        '$region'            => 'Washington',
                        '$country'           => 'US',
                        '$zipcode'           => '98112'
                    }
                ],
                '$listed_items'     => [
                    {
                        '$price'             => 2950000000, # $2950.00
                        '$currency_code'     => 'USD',
                        '$tags'              => ['heat', 'washer/dryer']
                    }
                ],
                '$images'           => [
                    {
                        '$md5_hash'          => '0cc175b9c0f1b6a831c399e269772661',
                        '$link'              => 'https://www.domain.com/file.png',
                        '$description'       => 'Billys picture'
                    }
                ],
                '$expiration_time'       => 1549063157000 # UNIX timestamp in milliseconds
            },
        
            # Send this information from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }
        
        return @@client.track("$update_content", listing_properties)
    end
    
    def create_account()
    
        # Sample $create_account event
        properties = {
            # Required Fields
            "$user_id"    => $user_id,
        
            # Supported Fields
            "$session_id"       => "gigtleqddo84l8cm15qe4il",
            "$user_email"       => $user_email,
            "$name"             => "Bill Jones",
            "$phone"            => "1-415-555-6040",
            "$referrer_user_id" => "janejane101",
            "$payment_methods"  => [
                {
                    "$payment_type"    => "$credit_card",
                    "$card_bin"        => "542486",
                    "$card_last4"      => "4444"
                }
            ],
            "$billing_address"  => {
                "$name"         => "Bill Jones",
                "$phone"        => "1-415-555-6040",
                "$address_1"    => "2100 Main Street",
                "$address_2"    => "Apt 3B",
                "$city"         => "New London",
                "$region"       => "New Hampshire",
                "$country"      => "US",
                "$zipcode"      => "03257"
            },
            "$shipping_address" => {
                "$name"         => "Bill Jones",
                "$phone"        => "1-415-555-6041",
                "$address_1"    => "2100 Main Street",
                "$address_2"    => "Apt 3B",
                "$city"         => "New London",
                "$region"       => "New Hampshire",
                "$country"      => "US",
                "$zipcode"      => "03257"
            },
            "$promotions"       => [
                {
                    "$promotion_id"     => "FriendReferral",
                    "$status"           => "$success",
                    "$referrer_user_id" => "janejane102",
                    "$credit_point"     => {
                        "$amount"             => 100,
                        "$credit_point_type"  => "account karma"
                    }
                }
            ],
        
            "$social_sign_on_type"   => "$twitter",
            "$account_types"         => ["merchant", "premium"],
        
            # Suggested Custom Fields
            "twitter_handle"          => "billyjones",
            "work_phone"              => "1-347-555-5921",
            "location"                => "New London, NH",
            "referral_code"           => "MIKEFRIENDS",
            "email_confirmed_status"  => "$pending",
            "phone_confirmed_status"  => "$pending",
        
            # Send this information from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }
        
        return @@client.track("$create_account", properties)
    end
    
    def verification()
    
        # Sample $verification event
        properties = {
            # Required Fields
            "$user_id"            => $user_id,
            "$session_id"         => "gigtleqddo84l8cm15qe4il",
            "$status"             => "$pending",
        
            # Optional fields if applicable
            "$verified_event"     => "$login",
            "$reason"             => "$automated_rule", # Verification was triggered based on risk score
            "$verification_type"  => "$sms",
            "$verified_value"     => "14155551212"
        }
        
        return @@client.track("$verification", properties)
    end
    
    def add_item_to_cart()
    
        # Sample $add_item_to_cart event
        properties = {
            # Required Fields
            "$user_id"           => $user_id,
    
            # Supported Fields
            "$session_id" => "gigtleqddo84l8cm15qe4il",
            "$item"       => {
                "$item_id"        => "B004834GQO",
                "$product_title"  => "The Slanket Blanket-Texas Tea",
                "$price"          => 39990000, # $39.99
                "$currency_code"  => "USD",
                "$upc"            => "6786211451001",
                "$sku"            => "004834GQ",
                "$brand"          => "Slanket",
                "$manufacturer"   => "Slanket",
                "$category"       => "Blankets & Throws",
                "$tags"           => ["Awesome", "Wintertime specials"],
                "$color"          => "Texas Tea",
                "$quantity"       => 16
            },
            "$brand_name"   => "sift",
            "$site_domain"  => "sift.com",
            "$site_country" => "US",
            # Send this information from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }
    
        return @@client.track("$add_item_to_cart", properties)
    end
    
    def order_status()
    
      # Sample $order_status event
        properties = {
            # Required Fields
            "$user_id"          => $user_id,
            "$order_id"         => "ORDER-28168441",
            "$order_status"     => "$canceled",
        
            # Optional Fields
            "$reason"           => "$payment_risk",
            "$webhook_id"       => "3ff1082a4aea8d0c58e3643ddb7a5bb87ffffeb2492dca33",
            "$source"           => "$manual_review",
            "$analyst"          => "someone@your-site.com",
            "$description"      => "Canceling because multiple fraudulent users on device",
        
            # Send this information from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }
      
        return @@client.track("$order_status", properties)
    end
    
    def link_session_to_user()
    
      # Sample $link_session_to_user event
        properties = {
            # Required Fields
            "$user_id"    => $user_id,
            "$session_id" => "gigtleqddo84l8cm15qe4il"
        }
        
        return @@client.track("$link_session_to_user", properties)
    end
    
    def content_status()
    
        # Sample $content_status event
        properties = {
            # Required Fields
            "$user_id"    => $user_id,
            "$content_id" => "9671500641",
            "$status"    => "$paused",
        
            # Send this information from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }
        
        return @@client.track("$content_status", properties)
    end
    
    def update_order()
    
        # Sample $update_order event
        properties = {
            # Required Fields
            "$user_id"          => $user_id,
            # Supported Fields
            "$session_id"       => "gigtleqddo84l8cm15qe4il",
            "$order_id"         => "ORDER-28168441",
            "$user_email"       => $user_email,
            "$amount"           => 115940000, # $115.94
            "$currency_code"    => "USD",
            "$billing_address"  => {
                "$name"         => "Bill Jones",
                "$phone"        => "1-415-555-6041",
                "$address_1"    => "2100 Main Street",
                "$address_2"    => "Apt 3B",
                "$city"         => "New London",
                "$region"       => "New Hampshire",
                "$country"      => "US",
                "$zipcode"      => "03257"
            },
            "$payment_methods"  => [
                {
                    "$payment_type"    => "$credit_card",
                    "$payment_gateway" => "$braintree",
                    "$card_bin"        => "542486",
                    "$card_last4"      => "4444"
                }
            ],
            "$brand_name"   => "sift",
            "$site_domain"  => "sift.com",
            "$site_country" => "US",
            "$ordered_from" => {
                "$store_id"      => "123",
                "$store_address" => {
                    "$name"       => "Bill Jones",
                    "$phone"      => "1-415-555-6040",
                    "$address_1"  => "2100 Main Street",
                    "$address_2"  => "Apt 3B",
                    "$city"       => "New London",
                    "$region"     => "New Hampshire",
                    "$country"    => "US",
                    "$zipcode"    => "03257"
                }
            },
            "$shipping_address"  => {
                "$name"          => "Bill Jones",
                "$phone"         => "1-415-555-6041",
                "$address_1"     => "2100 Main Street",
                "$address_2"     => "Apt 3B",
                "$city"          => "New London",
                "$region"        => "New Hampshire",
                "$country"       => "US",
                "$zipcode"       => "03257"
            },
            "$expedited_shipping"       => true,
            "$shipping_method"          => "$physical",
            "$shipping_carrier"         => "UPS",
            "$shipping_tracking_numbers"=> ["1Z204E380338943508", "1Z204E380338943509"],
            "$items"                    => [
                {
                    "$item_id"        => "12344321",
                    "$product_title"  => "Microwavable Kettle Corn: Original Flavor",
                    "$price"          => 4990000, # $4.99
                    "$upc"            => "097564307560",
                    "$sku"            => "03586005",
                    "$brand"          => "Peters Kettle Corn",
                    "$manufacturer"   => "Peters Kettle Corn",
                    "$category"       => "Food and Grocery",
                    "$tags"           => ["Popcorn", "Snacks", "On Sale"],
                    "$quantity"       => 4
                },
                {
                    "$item_id"        => "B004834GQO",
                    "$product_title"  => "The Slanket Blanket-Texas Tea",
                    "$price"          => 39990000, # $39.99
                    "$upc"            => "6786211451001",
                    "$sku"            => "004834GQ",
                    "$brand"          => "Slanket",
                    "$manufacturer"   => "Slanket",
                    "$category"       => "Blankets & Throws",
                    "$tags"           => ["Awesome", "Wintertime specials"],
                    "$color"          => "Texas Tea",
                    "$quantity"       => 2
                }
            ],
            # For marketplaces, use $seller_user_id to identify the seller
            "$seller_user_id"     => "slinkys_emporium",
        
            "$promotions"         => [
                {
                    "$promotion_id" => "FirstTimeBuyer",
                    "$status"       => "$success",
                    "$description"  => "$5 off",
                    "$discount"     => {
                    "$amount"                   => 5000000,  # $5.00
                    "$currency_code"            => "USD",
                    "$minimum_purchase_amount"  => 25000000  # $25.00
                    }
                }
            ],
        
            # Sample Custom Fields
            "digital_wallet"      => "apple_pay", # "google_wallet", etc.
            "coupon_code"         => "dollarMadness",
            "shipping_choice"     => "FedEx Ground Courier",
            "is_first_time_buyer" => false,
        
            # Send this information from a BROWSER client.
            "$browser"    => {
                "$user_agent"       => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                "$accept_language"  => "en-US",
                "$content_language" => "en-GB"
            }
        }
        
        return @@client.track("$update_order", properties)
    end
    
end
