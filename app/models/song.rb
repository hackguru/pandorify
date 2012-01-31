class Song < ActiveRecord::Base
  has_many :listens
  belongs_to :application
  
  def update_popularity
    if self.application.name == "Spotify"
      url = "http://ws.spotify.com/lookup/1/.json?uri=spotify:track:#{self.get_uri}"
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request).body
      new_info = JSON.parse(response)
      new_info['track']['popularity']
    end
  end
  
  def get_uri
    if self.application.name == "Spotify"
      self.url.sub("http://open.spotify.com/track/","").strip
     end   
  end
  
  def update_popularity_all
    
  end
end
