require "sift"

class ScoreAPI

    @@client = Sift::Client.new(:api_key => ENV["API_KEY"])

    def user_score()
        return @@client.get_user_score("billy_jones_301")
    end

end
