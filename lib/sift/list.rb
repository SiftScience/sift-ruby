module Sift
  module ListRepresenter
    include Representable::JSON
    include Representable::Object

    property :has_more
    property :total_results

    # property :data, :extend => RefRepresenter, :class: Ref

    def self.of(representer, klass)
      l = ListRepresenter.clone
      l.collection :data, extend: representer, class: klass
      l
    end
  end


  class List < OpenStruct; end
end
