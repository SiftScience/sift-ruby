require "sift"

class PSPMerchantAPI

    @@client = Sift::Client.new(:api_key => ENV["API_KEY"], :account_id => ENV["ACCOUNT_ID"])

    def create_psp_merchant_profile(merchant_id)

        # Sample psp_merchant_profile
        properties={
            "id": merchant_id,
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

    def get_psp_merchant_profile(merchant_id)
        return @@client.get_a_psp_merchant_profile(merchant_id)
    end
    
    def get_all_psp_merchant_profiles(batch_size = nil, batch_token = nil)       
        return @@client.get_psp_merchant_profiles(batch_size, batch_token)
    end

end
