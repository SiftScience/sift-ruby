
module Sift

  module Resource

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.include(InstanceMethods)
    end

    module ClassMethods

      BASE_URI = "https://api3.siftscience.com/v3/accounts/"

      def resource_uri(path)
        BASE_URI + Sift.account_id + path
      end

      def post(uri, options = {})
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
          raise(RuntimeError, "Request failed: #{response.code}\n#{response.body}", caller)
        end
      end

    end

    module InstanceMethods
    end

  end

end
