class AddDurationToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :duration, :float
  end
end
