class Echonest
  def self.perform
    Song.update_song_characteristics
  end
end