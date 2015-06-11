
module Sift

  class HttpRequestError < StandardError
    attr_reader :http_status
    attr_reader :body

    def initialize(http_status, body)
      @http_status = http_status
      @body = body
    end
  end

  module Resource

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      BASE_URI = "https://api3.siftscience.com/v3/accounts/"

      def resource_uri(path)
        raise(RuntimeError, "Sift.account_id hasn't been set") if Sift.account_id.nil?
        BASE_URI + Sift.account_id + path
      end

      def post(uri, options = {})
        http_request do 
          HTTParty.post(uri, options.merge(default_options))
        end
      end

      def put(uri, options = {})
        http_request do 
          HTTParty.put(uri, options.merge(default_options))
        end
      end

      def get(uri, options = {})
        http_request do 
          HTTParty.get(uri, options.merge(default_options))
        end
      end

    private
      def default_options
        {
          headers: { 
            "Authorization" => "Basic #{Sift.api_key}", 
            "User-Agent" => "sift-ruby/#{Sift::VERSION}", 
            "Content-Type" => "application/json", 
          },
        }
      end

      def http_request(&blk)
        response = blk.call
        if response.success?
          response.body
        else
          raise(HttpRequestError.new(response.code, response.body), "Request failed", caller)
        end
      end

    end
  end
end
