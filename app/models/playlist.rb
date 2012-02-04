class Playlist < ActiveRecord::Base
  has_and_belongs_to_many :songs, :join_table => "songs_playlists"
  belongs_to :facebook
end
