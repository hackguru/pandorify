class AddLoudnessToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :loudness, :float
  end
end
