module Sift
  # You can use the data returned from this endpoint to help
  # investigate suspicious devices. Data like the first time you've
  # seen a device in addition to how the Sift Science network has
  # labeled a device can help you determine whether to allow a user to
  # continue interacting with your site.
  class Device < OpenStruct
    include Resource

    class << self
      def retrieve(device_id)
        json = get(resource_uri("/devices/#{device_id}"))
        Device.new.extend(DeviceRepresenter).from_json(json)
      end
    end

    # Updates the label for this device to "bad." Use this method when
    # you would like to prevent the device from continuing to use your
    # site.
    def label_bad!
      update_label(Label::BAD)
    end

    # Updates the label for this device to "not bad." Calling this on
    # a device with a high score that you have determined not to be
    # bad helps Sift learn about behaviors on your site.
    def label_not_bad!
      update_label(Label::NOT_BAD)
    end

    # Returns true if the device has been labeled bad.
    def bad?
      labeled? && self.label == Label::BAD
    end

    # Returns true if the device has been labeled not bad.
    def not_bad?
      self.label == Label::NOT_BAD
    end

    # Returns true if the device has been labeled.
    def labeled?
      !(self.label.nil? || self.label.empty?)
    end

    private
    def update_label(new_label)
      json = self.class.put(self.class.resource_uri("/devices/#{id}/label"),
                            body: Label.new(new_label).extend(LabelRepresenter).to_json)
      received_label = Label.new.extend(LabelRepresenter).from_json(json)
      self.label = received_label.label
    end

  end

  class SessionTime < OpenStruct; end
  class Network < OpenStruct; end

  # Private
  module SessionTimeRepresenter
    extend SiftRepresentable

    include Representable::JSON
    include Representable::Object

    time_property :time
  end

  module DeviceRepresenter
    extend SiftRepresentable

    include Representable::JSON
    include Representable::Object

    property :id
    property :label

    time_property :labeled_at
    time_property :first_seen

    property :sessions,
             :extend => ListRepresenter.of(SessionTimeRepresenter, SessionTime),
             :class => List

    property :network, :class => Network do
      extend SiftRepresentable

      time_property :first_seen
      property :score
    end
  end
end
