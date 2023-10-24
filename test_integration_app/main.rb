require 'rubygems'
require 'multi_json'
require_relative '../test_integration_app/globals.rb'
require_relative '../test_integration_app/events_api/test_events_api.rb'
require_relative '../test_integration_app/score_api/test_score_api.rb'
require_relative '../test_integration_app/decisions_api/test_decisions_api.rb'
require_relative  '../test_integration_app/verification_api/test_verification_api.rb'
require_relative '../test_integration_app/psp_merchants_api/test_psp_merchant_api.rb'

class Utils
    def isOk(response)
        # expect http status 200 and api status 0 or http status 201 if apiStatus exists.     
        if(response.api_status)
            return ((response.api_status == 0) && (response.http_status_code == 200 || response.http_status_code == 201))
        else
            return ((response.http_status_code == 200) || (response.http_status_code == 201))
        end
    end
end

class Main
    def testMethods
       objUtils = Utils.new()
        objEvents = EventsAPI.new()
        objScore = ScoreAPI.new()
        objDecision = DecisionAPI.new()
        objVerification = VerificationAPI.new()
        objPSPMerchant = PSPMerchantAPI.new()

        raise "Failed" unless objUtils.isOk(objEvents.login())     
        raise "Failed" unless objUtils.isOk(objEvents.transaction())
        raise "Failed" unless objUtils.isOk(objEvents.create_order())
        raise "Failed" unless objUtils.isOk(objEvents.create_content())
        raise "Failed" unless objUtils.isOk(objEvents.create_content_listing())
        raise "Failed" unless objUtils.isOk(objEvents.create_content_message())
        raise "Failed" unless objUtils.isOk(objEvents.update_account())
        raise "Failed" unless objUtils.isOk(objEvents.update_content_listing())
        raise "Failed" unless objUtils.isOk(objEvents.create_account())
        raise "Failed" unless objUtils.isOk(objEvents.verification())
        raise "Failed" unless objUtils.isOk(objEvents.add_item_to_cart())
        raise "Failed" unless objUtils.isOk(objEvents.order_status())
        raise "Failed" unless objUtils.isOk(objEvents.link_session_to_user())
        raise "Failed" unless objUtils.isOk(objEvents.content_status())
        raise "Failed" unless objUtils.isOk(objEvents.update_order())
        puts "Events API Tested"      

        raise "Failed" unless objUtils.isOk(objScore.user_score()) == false
        puts "Score API Tested"

        raise "Failed" unless objUtils.isOk(objDecision.apply_user_decision()) == false
        raise "Failed" unless objUtils.isOk(objDecision.apply_order_decision()) == false
        puts "Decisions API Tested"

        raise "Failed" unless objUtils.isOk(objVerification.send())
        puts "Verifications API Tested"

        raise "Failed" unless objUtils.isOk(objPSPMerchant.create_psp_merchant_profile())
        raise "Failed" unless objUtils.isOk(objPSPMerchant.get_psp_merchant_profile())
        raise "Failed" unless objUtils.isOk(objPSPMerchant.get_all_psp_merchant_profiles())
        puts "PSP Merchant API Tested"

    end
end

objMain = Main.new()
objMain.testMethods()
