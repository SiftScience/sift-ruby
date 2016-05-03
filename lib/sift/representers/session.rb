module Sift
  module Representers
    module Session
      extend Base
      include Representable::JSON
      include Representable::Object

      property :id
      time_property :time
      property :device, extend: DeviceRepresenter, class: Device
    end
  end
end
