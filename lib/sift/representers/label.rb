module Sift
  module Representers
    module Label
      include Representable::JSON
      include Representable::Object

      property :label
    end
  end
end
