class Song < ActiveRecord::Base
  has_many :listens
  belongs_to :application
  belongs_to :artist
  belongs_to :album
  
  def update_popularity
    if self.application.name == "Spotify"
      url = "http://ws.spotify.com/lookup/1/.json?uri=spotify:track:#{self.get_uri}"
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request).body
      new_info = JSON.parse(response)
      self.popularity = new_info['track']['popularity']
      
      new_album_url = new_info['track']['album']['href'].sub("spotify:album:","http://open.spotify.com/album/").strip
      new_artist_url = new_info['track']['artists'][0]['href'].sub("spotify:artist:","http://open.spotify.com/artist/").strip
      
      new_album = Album.find_or_create_by_url(new_album_url)
      new_album.name = new_info['track']['album']['name']
      self.album = new_album
      
      new_artist = Album.find_or_create_by_url(new_artist_url)
      new_artist.name = new_info['track']['artists'][0]['name']
      self.artist = new_artist
      
      self.save!
      new_album.save!
      new_artist.save!
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
