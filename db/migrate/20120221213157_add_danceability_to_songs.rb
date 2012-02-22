class AddDanceabilityToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :danceability, :float
  end
end
