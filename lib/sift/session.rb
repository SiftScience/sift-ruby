module Sift

  # Representation of JSON fields return through the API
  module SessionRepresenter
    include Representable::JSON
    include Representable::Object

    property :id
    property :label
    property :labeled_at_millis, as: :labeled_at
    property :first_seen
    property :time

    property :device, extend: DeviceRepresenter, class: Device
  end

  class Session < Struct.new :id, :time, :device

    include Resource

    class << self
      def retrieve(session_id)
        json = get(resource_uri("/sessions/#{session_id}"))
        Session.new.extend(SessionRepresenter).from_json(json)
      end
    end

  end

end
