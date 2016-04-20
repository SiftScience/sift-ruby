module Sift
  # You can use the data returned from this endpoint to help
  # investigate suspicious devices. Data like the first time you've
  # seen a device in addition to how the Sift Science network has
  # labeled a device can help you determine whether to allow a user to
  # continue interacting with your site.
  class Device < OpenStruct
    extend Forwardable

    def self.retrieve(device_id)
      device = self.new(id: device_id)
      json = device.fetch_json
      device.extend(Representers::Device).from_json(json)
      device
    end

    def initialize(*args)
      super
      @label_obj = ::Sift::Entities::Label.new(self)
    end

    def_delegators :@label_obj, :bad?, :not_bad?, :labeled?

    def label_bad!
      label_obj.label_bad!
      sync_with_label_obj!
    end

    def label_not_bad!
      label_obj.label_not_bad!
      sync_with_label_obj!
    end

    def fetch_json
      RestWrapper.get(url)
    end

    def url
      RestWrapper.base_url + "/devices/#{id}"
    end

    private

    attr_reader :label_obj

    def sync_with_label_obj!
      self.label = label_obj.label
    end

    def label_url
      url + "/label"
    end
  end
end
