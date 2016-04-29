module Sift
  module LabelRepresenter
    include Representable::JSON
    include Representable::Object

    property :label
  end

  class Label < OpenStruct
    BAD = 'bad'
    NOT_BAD = 'not_bad'
  end
end


