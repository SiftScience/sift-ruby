module Sift
  module SiftRepresentable
    def time_property name
      self.property name, :parse_filter => lambda{|value, doc, *args|
        # The Sift API returns timestamps in millis since the Epoch
        Time.at(value / 1000) if value
      }
    end
  end
end
