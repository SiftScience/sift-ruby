require "sift"

class VerificationAPI

    @@client = Sift::Client.new(:api_key => ENV["API_KEY"],  :version => 1.1)

    def send()
        properties = {
            "$user_id"            => $user_id,
            "$send_to"            => $user_email,
            "$verification_type"            => "$email",
            "$brand_name"         => "MyTopBrand",
            "$language"           => "en",
            "$site_country" => "IN",
            "$event" => {
                "$session_id" => "SOME_SESSION_ID",
                "$verified_event" => "$login",
                "$verified_entity_id" => "SOME_SESSION_ID",
                "$reason" => "$automated_rule",
                "$ip" => "192.168.1.1",
                "$browser" => {
                    "$user_agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
                    "$accept_language" => "en-US",
                    "$content_language" => "en-GB"
                }
           }
        }
        
        return @@client.verification_send(properties)
    end

end
