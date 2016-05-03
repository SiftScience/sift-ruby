module Sift
  module Representers
    module List
      include Representable::JSON
      include Representable::Object

      property :has_more
      property :total_results

      # property :data, extend: RefRepresenter, class: Entities::Blank

      def self.of(representer, klass)
        l = self.clone
        l.collection :data, extend: representer, class: klass
        l
      end
    end
  end
end
