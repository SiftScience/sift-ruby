require 'httparty'
require 'multi_json'
require 'ostruct'
require 'representable'
require 'representable/json'
require 'representable/json/collection'
require 'representable/object'

require 'sift/version'
require 'sift/error'
require 'sift/rest_wrapper'
require 'sift/entities'
require 'sift/device'
require 'sift/session'
require 'sift/representers'
require 'sift/client'

module Sift
  extend self

  # :logger sets the Output logger to use within the client.
  # This can be left uninitializaed
  # but is useful for debugging.
  attr_writer :api_key, :account_id, :logger

  def api_key
    @api_key || raise(MissingApiKey)
  end

  def account_id
    @account_id || raise(MissingAccountId)
  end

  # Returns the path for the current API version
  def current_rest_api_path
    "/v#{API_VERSION}/events"
  end

  def current_users_label_api_path(user_id)
    # This API version is a minor version ahead of the /events API
    "/v#{API_VERSION}/users/#{URI.encode(user_id)}/labels"
  end

  def info(msg)
    @logger.info(msg) if @logger
  end

  def warn(msg)
    @logger.warn(msg) if @logger
  end

  def error(msg)
    @logger.error(msg) if @logger
  end

  def fatal(msg)
    @logger.fatal(msg) if @logger
  end

end
