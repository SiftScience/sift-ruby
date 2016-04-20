module Sift
  module Representers
    module Device
      extend Base

      include Representable::JSON
      include Representable::Object

      property :id
      property :label

      time_property :labeled_at
      time_property :first_seen

      property :sessions,
               :extend => List.of(SessionTime, Entities::Blank),
               :class => Entities::Blank

      property :network, :class => Entities::Blank do
        extend Base

        time_property :first_seen
        property :score
      end
    end
  end
end
