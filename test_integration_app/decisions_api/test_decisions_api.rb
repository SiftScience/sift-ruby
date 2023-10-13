require "sift"

class DecisionAPI

    @@client = Sift::Client.new(:api_key => ENV["api_key"], :account_id => ENV["account_id"])

    def apply_user_decision()
    
        # Sample $login event
          properties = {
            "decision_id": "block_user_payment_abuse",
            "description": "User linked to three other payment abusers and ordering high value items",
            "source": "manual_review",
            "analyst": "analyst@example.com",
            "user_id": "userId"
          }
  
          return @@client.apply_decision(properties)
      end

      def apply_order_decision()
    
        # Sample $login event
          properties = {
            "decision_id": "block_bad_order",
            "description": "applied via the high priority queue, queued user because their risk score exceeded 85",
            "source": "AUTOMATED_RULE",
            "user_id": "userId",
            "order_id": "orderId"
          }
  
          return @@client.apply_decision(properties)
      end

end
