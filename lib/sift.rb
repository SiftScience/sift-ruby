require_relative './sift/version'
require_relative './sift/client'
require 'erb'

module Sift

  # Returns the path for the specified API version
  def self.rest_api_path(version=API_VERSION)
    "/v#{version}/events"
  end

  # Returns the path for the specified API version
  def self.verification_api_send_path(version=VERIFICATION_API_VERSION)
    "/v#{version}/verification/send"
  end

  # Returns the path for the specified API version
  def self.verification_api_resend_path(version=VERIFICATION_API_VERSION)
    "/v#{version}/verification/resend"
  end

  # Returns the path for the specified API version
  def self.verification_api_check_path(version=VERIFICATION_API_VERSION)
    "/v#{version}/verification/check"
  end

  # Returns the Score API path for the specified user ID and API version
  def self.score_api_path(user_id, version=API_VERSION)
    "/v#{version}/score/#{ERB::Util.url_encode(user_id)}/"
  end

  # Returns the User Score API path for the specified user ID and API version
  def self.user_score_api_path(user_id, version=API_VERSION)
    "/v#{version}/users/#{ERB::Util.url_encode(user_id)}/score"
  end

  # Returns the users API path for the specified user ID and API version
  def self.users_label_api_path(user_id, version=API_VERSION)
    "/v#{version}/users/#{ERB::Util.url_encode(user_id)}/labels"
  end

  # Returns the path for the Workflow Status API
  def self.workflow_status_path(account_id, run_id)
    "/v3/accounts/#{ERB::Util.url_encode(account_id)}" \
      "/workflows/runs/#{ERB::Util.url_encode(run_id)}"
  end

  # Returns the path for User Decisions API
  def self.user_decisions_api_path(account_id, user_id)
    "/v3/accounts/#{ERB::Util.url_encode(account_id)}" \
      "/users/#{ERB::Util.url_encode(user_id)}/decisions"
  end

  # Returns the path for Orders Decisions API
  def self.order_decisions_api_path(account_id, order_id)
    "/v3/accounts/#{ERB::Util.url_encode(account_id)}" \
      "/orders/#{ERB::Util.url_encode(order_id)}/decisions"
  end

  # Returns the path for Session Decisions API
  def self.session_decisions_api_path(account_id, user_id, session_id)
    "/v3/accounts/#{ERB::Util.url_encode(account_id)}" \
      "/users/#{ERB::Util.url_encode(user_id)}" \
      "/sessions/#{ERB::Util.url_encode(session_id)}/decisions"
  end

  # Returns the path for Content Decisions API
  def self.content_decisions_api_path(account_id, user_id, content_id)
    "/v3/accounts/#{ERB::Util.url_encode(account_id)}" \
      "/users/#{ERB::Util.url_encode(user_id)}" \
      "/content/#{ERB::Util.url_encode(content_id)}/decisions"
  end

  # Returns the path for psp Merchant API
  def self.psp_merchant_api_path(account_id)
    "/v3/accounts/#{ERB::Util.url_encode(account_id)}" \
    "/psp_management/merchants"
  end

  # Returns the path for psp Merchant with id
  def self.psp_merchant_id_api_path(account_id, merchant_id)
    "/v3/accounts/#{ERB::Util.url_encode(account_id)}" \
    "/psp_management/merchants/#{ERB::Util.url_encode(merchant_id)}"
  end

  # Module-scoped public API key
  class << self
    attr_accessor :api_key
  end

  # Module-scoped account ID
  class << self
    attr_accessor :account_id
  end

  # Sets the Output logger to use within the client. This can be left uninitializaed
  # but is useful for debugging.
  def self.logger=(logger)
    @logger = logger
  end

  def self.info(msg)
    @logger.info(msg) if @logger
  end

  def self.warn(msg)
    @logger.warn(msg) if @logger
  end

  def self.error(msg)
    @logger.error(msg) if @logger
  end

  def self.fatal(msg)
    @logger.fatal(msg) if @logger
  end
end
