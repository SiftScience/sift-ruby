module Sift
  module SessionRepresenter
    extend SiftRepresentable
    include Representable::JSON
    include Representable::Object

    property :id
    time_property :time
    property :device, extend: DeviceRepresenter, class: Device
  end

  class Session < OpenStruct
    include Resource

    class << self
      def retrieve(session_id)
        json = get(resource_uri("/sessions/#{session_id}"))
        puts json.inspect
        Session.new.extend(SessionRepresenter).from_json(json)
      end
    end
  end
end
