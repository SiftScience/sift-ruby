module Sift
  class Error < StandardError
  end

  class ConfigError < Error
  end

  class HttpRequestError < Error
    attr_reader :http_status
    attr_reader :body

    def initialize(http_status, body)
      @http_status = http_status
      @body = body
    end
  end
end
