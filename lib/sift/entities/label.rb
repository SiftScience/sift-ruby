module Sift
  module Entities
    class Label
      BAD = 'bad'
      NOT_BAD = 'not_bad'

      extend Forwardable

      def_delegators :@device, :label, :label=

      attr_reader :device

      def initialize(device)
        @device = device
      end

      # Updates the label for this device to "bad." Use this method when
      # you would like to prevent the device from continuing to use your
      # site.
      def label_bad!
        update!(BAD)
      end

      # Updates the label for this device to "not bad." Calling this on
      # a device with a high score that you have determined not to be
      # bad helps Sift learn about behaviors on your site.
      def label_not_bad!
        update!(NOT_BAD)
      end

      # Returns true if the device has been labeled bad.
      def bad?
        labeled? && label == Label::BAD
      end

      # Returns true if the device has been labeled not bad.
      def not_bad?
        labeled? && label == Label::NOT_BAD
      end

      # Returns true if the device has been labeled.
      def labeled?
        !label.to_s.empty?
      end

      protected

      def to_json
        Representers::Label.new(self).to_json
      end

      private

      def update!(new_label)
        updated_rep = representer(label: new_label)
        json = RestWrapper.put(url, body: updated_rep.to_json)
        self.label = representer.from_json(json).label
      end

      def representer(options={})
        self.class.new(OpenStruct.new(options)).extend(Representers::Label)
      end

      def url
        device.url + "/label"
      end
    end
  end
end
