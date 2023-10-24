require "sift"

class ScoreAPI

    @@client = Sift::Client.new(:api_key => ENV["api_key"])

    def user_score()      
        return @@client.get_user_score("billy_jones_301", :include_score_percentiles => "true")
    end

end
