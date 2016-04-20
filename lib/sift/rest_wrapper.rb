module Sift
  class RestWrapper
    BASE_URI = "https://api3.siftscience.com/v3/accounts/"

    class << self
      def base_url
        "#{RestWrapper::BASE_URI}#{Sift.account_id}"
      end

      def post(uri, options = {})
        handle_response(
          HTTParty.post(uri, default_options.merge(options)))
      end

      def put(uri, options = {})
        handle_response(
          HTTParty.put(uri, default_options.merge(options)))
      end

      def get(uri, options = {})
        handle_response(
          HTTParty.get(uri, default_options.merge(options)))
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

      def handle_response(response)
        if response.success?
          response.body
        else
          error = HttpRequestError.new
          raise error, error.message, caller
        end
      end
    end

  end
end
