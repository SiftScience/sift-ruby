module Sift
  class Errors < StandardError
  end

  class ApiError < StandardError
    attr_reader :message, :response

    def initialize(message, response)
      @message = message
      @response = response
    end
  end
end
