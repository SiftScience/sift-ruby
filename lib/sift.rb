require 'httparty'
require 'multi_json'
require 'ostruct'
require 'representable'
require 'representable/json'
require 'representable/json/collection'
require 'representable/object'

require 'sift/version'
require 'sift/resource'
require 'sift/helpers'
require 'sift/list'
require 'sift/ref'
require 'sift/label'
require 'sift/device'
require 'sift/session'
require 'sift/credentials'
require 'sift/client'

module Sift

  # Returns the path for the current API version
  def self.current_rest_api_path
    "/v#{API_VERSION}/events"
  end

  def self.current_users_label_api_path(user_id)
    # This API version is a minor version ahead of the /events API
    "/v#{API_VERSION}/users/#{URI.encode(user_id)}/labels"
  end
 
  # Adding module scoped public API key 
  class << self
    attr_accessor :api_key
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
