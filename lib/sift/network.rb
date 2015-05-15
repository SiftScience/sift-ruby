module Sift

  module NetworkRepresenter
    include Representable::JSON
    include Representable::Object
    property :first_seen
    property :score
  end

  class Network < Struct.new :first_seen, :score
    def risky?
      self.score > 0.5
    end
  end

end
