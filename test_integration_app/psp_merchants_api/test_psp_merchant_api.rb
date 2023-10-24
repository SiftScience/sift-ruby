require "sift"

class PSPMerchantAPI

    @@client = Sift::Client.new(:api_key => ENV["api_key"], :account_id => ENV["account_id"])

    def create_psp_merchant_profile()
           
        # Sample psp_merchant_profile  
        properties={
            "id": "merchant_id-"<< rand.to_s[5..10],
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
        
        return @@client.create_psp_merchant_profile(properties)
    end
    
    def get_psp_merchant_profile()        
        return @@client.get_a_psp_merchant_profile("api-key1-2")
    end
    
    def get_all_psp_merchant_profiles(batch_size = nil, batch_token = nil)       
        return @@client.get_psp_merchant_profiles(batch_size, batch_token)
    end

end
