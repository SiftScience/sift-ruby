module Sift

  module NetworkRepresenter
    include Representable::JSON
    include Representable::Object
    property :internal_first_seen, as: :first_seen
    property :score
  end

  class Network < Struct.new :internal_first_seen, :score
    def risky?
      self.score >= 0.7
    end

    def first_seen
      # NB. The API returns timestamps in millis since the Epoch
      Time.at(self.internal_first_seen / 1000) if self.internal_first_seen
    end
  end

end
