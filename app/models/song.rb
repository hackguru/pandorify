require 'cgi'
class Song < ActiveRecord::Base
  has_many :listens
  belongs_to :application
  belongs_to :artist
  belongs_to :album
  has_and_belongs_to_many :playlists, :join_table => "songs_playlists"

  scope :song_based_on_sorted_listens_by_user_since, lambda { |time| {
        :select => "#{Song.table_name}.*, count(DISTINCT #{Facebook.table_name}.id) as user_count",
        :joins => "LEFT JOIN #{Listen.table_name} ON #{Song.table_name}.id = #{Listen.table_name}.song_id LEFT JOIN #{Facebook.table_name} ON #{Listen.table_name}.facebook_id = #{Facebook.table_name}.id",
        :conditions => ["#{Listen.table_name}.start_time > ?", time],
        :group => "#{Song.table_name}.id, #{Song.table_name}.identifier, #{Song.table_name}.title, #{Song.table_name}.url, #{Song.table_name}.created_at, #{Song.table_name}.updated_at, #{Song.table_name}.application_id, #{Song.table_name}.popularity, #{Song.table_name}.artist_id, #{Song.table_name}.album_id, #{Song.table_name}.tiny_song,#{Song.table_name}.duration",
        :order => "user_count DESC, coalesce(#{Song.table_name}.popularity, 0) DESC"
  }}
  
  scope :song_based_on_sorted_listens_by_user,
        :select => "#{Song.table_name}.*, count(DISTINCT #{Facebook.table_name}.id) as user_count",
        :joins => "LEFT JOIN #{Listen.table_name} ON #{Song.table_name}.id = #{Listen.table_name}.song_id LEFT JOIN #{Facebook.table_name} ON #{Listen.table_name}.facebook_id = #{Facebook.table_name}.id",
        :group => "#{Song.table_name}.id, #{Song.table_name}.identifier, #{Song.table_name}.title, #{Song.table_name}.url, #{Song.table_name}.created_at, #{Song.table_name}.updated_at, #{Song.table_name}.application_id, #{Song.table_name}.popularity, #{Song.table_name}.artist_id, #{Song.table_name}.album_id, #{Song.table_name}.tiny_song,#{Song.table_name}.duration",
        :order => "user_count DESC, coalesce(#{Song.table_name}.popularity, 0) DESC"

  scope :song_based_on_sorted_listens_by_friends, lambda { |user| {
        :select => "#{Song.table_name}.*, count(DISTINCT #{Facebook.table_name}.id) as user_count",
        :joins => "LEFT JOIN #{Listen.table_name} ON #{Song.table_name}.id = #{Listen.table_name}.song_id LEFT JOIN #{Facebook.table_name} ON #{Listen.table_name}.facebook_id = #{Facebook.table_name}.id LEFT JOIN #{Friendship.table_name} ON #{Facebook.table_name}.id = #{Friendship.table_name}.friend_id AND #{Friendship.table_name}.user_id = #{user.id}",
        :conditions => ["#{Friendship.table_name}.user_id = ?", user.id],
        :group => "#{Song.table_name}.id, #{Song.table_name}.identifier, #{Song.table_name}.title, #{Song.table_name}.url, #{Song.table_name}.created_at, #{Song.table_name}.updated_at, #{Song.table_name}.application_id, #{Song.table_name}.popularity, #{Song.table_name}.artist_id, #{Song.table_name}.album_id, #{Song.table_name}.tiny_song,#{Song.table_name}.duration",
        :order => "user_count DESC, coalesce(#{Song.table_name}.popularity, 0) DESC"
  }}

  #first id is user and second one is time we want for after that
  scope :song_based_on_sorted_listens_by_friends_after, lambda { |*args| {
        :select => "#{Song.table_name}.*, count(DISTINCT #{Facebook.table_name}.id) as user_count",
        :joins => "LEFT JOIN #{Listen.table_name} ON #{Song.table_name}.id = #{Listen.table_name}.song_id LEFT JOIN #{Facebook.table_name} ON #{Listen.table_name}.facebook_id = #{Facebook.table_name}.id LEFT JOIN #{Friendship.table_name} ON #{Facebook.table_name}.id = #{Friendship.table_name}.friend_id AND #{Friendship.table_name}.user_id = #{args.first.id}",
        :conditions => ["#{Friendship.table_name}.user_id = ? AND start_time > ?", args.first.id, args.second],
        :group => "#{Song.table_name}.id, #{Song.table_name}.identifier, #{Song.table_name}.title, #{Song.table_name}.url, #{Song.table_name}.created_at, #{Song.table_name}.updated_at, #{Song.table_name}.application_id, #{Song.table_name}.popularity, #{Song.table_name}.artist_id, #{Song.table_name}.album_id, #{Song.table_name}.tiny_song,#{Song.table_name}.duration",
        :order => "user_count DESC, coalesce(#{Song.table_name}.popularity, 0) DESC"
  }}
  
  scope :common_songs, lambda { |*args| {
        :select => "#{Song.table_name}.*",
        :joins => "JOIN #{Listen.table_name} ON #{Song.table_name}.id = #{Listen.table_name}.song_id JOIN #{Facebook.table_name} ON #{Listen.table_name}.facebook_id = #{Facebook.table_name}.id AND (#{Facebook.table_name}.id = #{args.first.id} OR #{Facebook.table_name}.id = #{args.second.id})",
        :group => "#{Song.table_name}.id, #{Song.table_name}.identifier, #{Song.table_name}.title, #{Song.table_name}.url, #{Song.table_name}.created_at, #{Song.table_name}.updated_at, #{Song.table_name}.application_id, #{Song.table_name}.popularity, #{Song.table_name}.artist_id, #{Song.table_name}.album_id, #{Song.table_name}.tiny_song,#{Song.table_name}.duration",
        :having => "count(DISTINCT #{Facebook.table_name}.id) > 1",
        :order => "coalesce(#{Song.table_name}.popularity, 0) DESC"
  }}

  # sample user_string: (#{Facebook.table_name}.id = #{args.first.id} OR #{Facebook.table_name}.id = #{args.second.id})
  scope :sort_based_on_common_song_count, lambda { |users_string| {
        :select => "#{Song.table_name}.*, count(DISTINCT #{Facebook.table_name}.id) as user_count",
        :joins => "JOIN #{Listen.table_name} ON #{Song.table_name}.id = #{Listen.table_name}.song_id JOIN #{Facebook.table_name} ON #{Listen.table_name}.facebook_id = #{Facebook.table_name}.id AND #{users_string}",
        :group => "#{Song.table_name}.id, #{Song.table_name}.identifier, #{Song.table_name}.title, #{Song.table_name}.url, #{Song.table_name}.created_at, #{Song.table_name}.updated_at, #{Song.table_name}.application_id, #{Song.table_name}.popularity, #{Song.table_name}.artist_id, #{Song.table_name}.album_id, #{Song.table_name}.tiny_song,#{Song.table_name}.duration",
        :order => "user_count DESC, count(DISTINCT #{Listen.table_name}.id) DESC, coalesce(#{Song.table_name}.popularity, 0) DESC"
  }}

  scope :not_common_songs, lambda { |*args| {
        :select => "#{Song.table_name}.*",
        :joins => "JOIN #{Listen.table_name} ON #{Song.table_name}.id = #{Listen.table_name}.song_id JOIN #{Facebook.table_name} ON #{Listen.table_name}.facebook_id = #{Facebook.table_name}.id AND (#{Facebook.table_name}.id = #{args.first.id} OR #{Facebook.table_name}.id = #{args.second.id})",
        :group => "#{Song.table_name}.id, #{Song.table_name}.identifier, #{Song.table_name}.title, #{Song.table_name}.url, #{Song.table_name}.created_at, #{Song.table_name}.updated_at, #{Song.table_name}.application_id, #{Song.table_name}.popularity, #{Song.table_name}.artist_id, #{Song.table_name}.album_id, #{Song.table_name}.tiny_song,#{Song.table_name}.duration",
        :having => "count(DISTINCT #{Facebook.table_name}.id) = 1",
        :order => "coalesce(#{Song.table_name}.popularity, 0) DESC"
  }}
    
  scope :song_based_on_sorted_listens_for_user, lambda { |user| {
        :select => "#{Song.table_name}.*, count(#{Listen.table_name}.id) as listen_count",
        :joins => "JOIN #{Listen.table_name} ON #{Song.table_name}.id = #{Listen.table_name}.song_id JOIN #{Facebook.table_name} ON #{Listen.table_name}.facebook_id = #{Facebook.table_name}.id AND #{Facebook.table_name}.id = #{user.id}",
        :group => "#{Song.table_name}.id, #{Song.table_name}.identifier, #{Song.table_name}.title, #{Song.table_name}.url, #{Song.table_name}.created_at, #{Song.table_name}.updated_at, #{Song.table_name}.application_id, #{Song.table_name}.popularity, #{Song.table_name}.artist_id, #{Song.table_name}.album_id, #{Song.table_name}.tiny_song,#{Song.table_name}.duration",
        :order => "count(#{Listen.table_name}.id) DESC, coalesce(#{Song.table_name}.popularity,0) DESC"  
  }}

  self.per_page = 20
  
  def update_popularity_and_duration
    if self.application.name == "Spotify"
      url = "http://ws.spotify.com/lookup/1/.json?uri=spotify:track:#{self.get_uri}"
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request).body
      new_info = JSON.parse(response)
      self.popularity = new_info['track']['popularity']
      self.duration = new_info['track']['length'].to_f
      
      new_album_url = new_info['track']['album']['href'].sub("spotify:album:","http://open.spotify.com/album/").strip
      new_artist_url = new_info['track']['artists'][0]['href'].sub("spotify:artist:","http://open.spotify.com/artist/").strip
      
      new_album = Album.find_or_create_by_url(new_album_url)
      new_album.name = new_info['track']['album']['name'][0..254] #only the first characters - might wanna change this later to text
      self.album = new_album
      
      new_artist = Artist.find_or_create_by_url(new_artist_url)
      new_artist.name = new_info['track']['artists'][0]['name'][0..254]  #only the first characters - might wanna change this later to text
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
    
  class << self
    extend ActiveSupport::Memoizable
  
    def update_all
      Song.all.each do |object|
        begin
          object.update_popularity_and_duration
        rescue
          next
        end
      end
    end

    def update_tiny_song_id
      list = Song.all(:conditions => {:tiny_song => nil})
      list.each do |obj|
        begin
          c = Curl::Easy.perform("http://tinysong.com/b/#{CGI.escape(obj.title.to_s + ' ' + obj.artist.name.to_s)}?format=json&key=6ac3d5b1d6d3cd0af4a54e32961edd58") # FROM Tinysong
          parsed_json = ActiveSupport::JSON.decode(c.body_str)
          obj.tiny_song = parsed_json['SongID'].to_s if parsed_json['SongID'].to_s.size != 0
          obj.save!          
        rescue
          next
        end
      end
    end
    
    def update_songs
      Song.update_all
      # Song.update_tiny_song_id
    end
    
    def perform
      self.update_songs
    end
    
  end
  
end
