class AddTempoToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :tempo, :float
  end
end
