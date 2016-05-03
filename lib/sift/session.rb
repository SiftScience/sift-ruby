module Sift
  class Session < OpenStruct
    def self.retrieve(session_id)
      json = RestWrapper.get(url(sessiond_id))
      self.new.extend(Representers::Session).from_json(json)
    end

    def self.url(session_id)
      RestWrapper.base_uri + "/sessions/#{session_id}"
    end
  end
end
