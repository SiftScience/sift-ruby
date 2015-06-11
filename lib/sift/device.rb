module Sift

  module TimestampRepresenter
    include Representable::JSON
    include Representable::Object
    property :internal_time, as: :time
  end

  class Timestamp < Struct.new :internal_time
    def time
      # NB. The API returns timestamps in millis since the Epoch
      Time.at(self.internal_time / 1000) if self.internal_time
    end
  end

  module ListRepresenter
    include Representable::JSON
    include Representable::Object

    property :has_more
    property :total_results
    collection :data, extend: TimestampRepresenter, class: Timestamp
  end

  class List < Struct.new :has_more, :total_results, :data
  end

  # Representation of JSON fields return through the API
  module DeviceRepresenter
    include Representable::JSON
    include Representable::Object

    property :id
    property :label
    property :internal_labeled_at, as: :labeled_at
    property :internal_first_seen, as: :first_seen

    property :network, extend: NetworkRepresenter, class: Network
    property :internal_session_timestamps, extend: ListRepresenter, class: List, as: :sessions
  end

  class Device < Struct.new :id, :label, :network,
                            :internal_session_timestamps,
                            :internal_first_seen,
                            :internal_labeled_at

    include Resource

    class << self
      def retrieve(device_id)
        json = get(resource_uri("/devices/#{device_id}"))
        Device.new.extend(DeviceRepresenter).from_json(json)
      end
    end

    def label_bad!
      update_label(Label::BAD)
    end

    def label_not_bad!
      update_label(Label::NOT_BAD)
    end

    def bad?
      labeled? && self.label == Label::BAD
    end

    def not_bad?
      self.label == Label::NOT_BAD
    end

    def labeled?
      !(self.label.nil? || self.label.empty?)
    end

    def labeled_at
      # NB. The API returns timestamps in millis since the Epoch
      Time.at(self.internal_labeled_at / 1000) if self.internal_labeled_at
    end

    def first_seen
      # NB. The API returns timestamps in millis since the Epoch
      Time.at(self.internal_first_seen / 1000) if self.internal_first_seen
    end

    def session_timestamps
      self.internal_session_timestamps.data.map(&:time)
    end

  private
    def update_label(new_label)
      json = self.class.put(self.class.resource_uri("/devices/#{id}/label"),
                            body: Label.new(new_label).extend(LabelRepresenter).to_json)
      received_label = Label.new.extend(LabelRepresenter).from_json(json)
      self.label = received_label.label
    end

  end

end
