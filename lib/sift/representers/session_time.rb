module Sift
  module Representers
    module SessionTime
      extend Base

      include Representable::JSON
      include Representable::Object

      time_property :time
    end
  end
end
