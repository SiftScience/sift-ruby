module Sift

  module LabelRepresenter
    include Representable::JSON
    include Representable::Object

    property :label
  end

  class Label < Struct.new :label

    BAD = 'bad'
    NOT_BAD = 'not_bad'

  end

end


