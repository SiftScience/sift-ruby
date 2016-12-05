module Sift
  # Top level Error
  class Error < StandardError
  end

  class ApiError < Error
    attr_reader :response

    def initialize(message, response)
      super(message)
      @response = response
    end
  end

  class InvalidArgument < Error
  end

  class ValidationError < Error
  end

end
