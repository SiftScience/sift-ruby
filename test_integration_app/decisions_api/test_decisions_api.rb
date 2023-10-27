require "sift"

class DecisionAPI

    @@client = Sift::Client.new(:api_key => ENV["API_KEY"], :account_id => ENV["ACCOUNT_ID"])

    def apply_user_decision()
          properties = {
            "decision_id": "integration_app_watch_account_abuse",
            "description": "User linked to three other payment abusers and ordering high value items",
            "source": "manual_review",
            "analyst": "analyst@example.com",
            "user_id": "userId"
          }

          return @@client.apply_decision(properties)
      end

      def apply_order_decision()
          properties = {
            "decision_id": "block_order_payment_abuse",
            "description": "applied via the high priority queue, queued user because their risk score exceeded 85",
            "source": "AUTOMATED_RULE",
            "user_id": "userId",
            "order_id": "orderId"
          }
  
          return @@client.apply_decision(properties)
      end

end
