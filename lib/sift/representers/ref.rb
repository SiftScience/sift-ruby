module Sift
  module Representers
    # A Representable that describes a reference to a resource
    module Ref
      include Representable::JSON
      include Representable::Object
      include Base

      # id of the referenced resource
      property :id
      # URI of the referenced resource
      property :href, :parse_filter => lambda{|value, doc, *args| URI.parse(value)}

      def self.ref_of representer
        r = RefRepresenter.clone
        r.instance_variable_set(:@representer, representer)
        r
      end

      def get
        # TODO
      end
    end
  end
end
