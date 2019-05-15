module Sift
  class Error < StandardError
  end

  class ApiError < Error
    attr_reader :message, :response

    def initialize(message, response)
      @message = message
      @response = response
    end
  end

  class ParseError < Error
  end
end
