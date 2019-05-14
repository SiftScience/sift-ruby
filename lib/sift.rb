require_relative './sift/version'
require_relative './sift/client'
require 'erb'

module Sift
  include ERB::Util

  # Returns the path for the specified API version
  def self.rest_api_path(version=API_VERSION)
    "/v#{version}/events"
  end

  # Returns the Score API path for the specified user ID and API version
  def self.score_api_path(user_id, version=API_VERSION)
    "/v#{version}/score/#{url_encode(user_id)}/"
  end

  # Returns the User Score API path for the specified user ID and API version
  def self.user_score_api_path(user_id, version=API_VERSION)
    "/v#{version}/users/#{url_encode(user_id)}/score"
  end

  # Returns the users API path for the specified user ID and API version
  def self.users_label_api_path(user_id, version=API_VERSION)
    "/v#{version}/users/#{url_encode(user_id)}/labels"
  end

  # Returns the path for the Workflow Status API
  def self.workflow_status_path(account_id, run_id)
    "/v3/accounts/#{url_encode(account_id)}" \
      "/workflows/runs/#{url_encode(run_id)}"
  end

  # Returns the path for User Decisions API
  def self.user_decisions_api_path(account_id, user_id)
    "/v3/accounts/#{url_encode(account_id)}" \
      "/users/#{url_encode(user_id)}/decisions"
  end

  # Returns the path for Orders Decisions API
  def self.order_decisions_api_path(account_id, order_id)
    "/v3/accounts/#{url_encode(account_id)}" \
      "/orders/#{url_encode(order_id)}/decisions"
  end

  # Returns the path for Session Decisions API
  def self.session_decisions_api_path(account_id, user_id, session_id)
    "/v3/accounts/#{url_encode(account_id)}" \
      "/users/#{url_encode(user_id)}" \
      "/sessions/#{url_encode(session_id)}/decisions"
  end

  # Returns the path for Content Decisions API
  def self.content_decisions_api_path(account_id, user_id, content_id)
    "/v3/accounts/#{url_encode(account_id)}" \
      "/users/#{url_encode(user_id)}" \
      "/content/#{url_encode(content_id)}/decisions"
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
