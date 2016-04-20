module Sift
  class Error < StandardError
  end

  class ConfigError < Error
  end

  class MissingApiKey < ConfigError
    def initialize
      super("Sift.api_key hasn't been set")
    end
  end

  class MissingAccountKey < ConfigError
    def initialize
      super("Sift.account_id hasn't been set")
    end
  end

  class HttpRequestError < Error
    attr_reader :http_status
    attr_reader :body

    def initialize(http_status, body)
      super("Request failed")
      @http_status = http_status
      @body = body
    end
  end
end
