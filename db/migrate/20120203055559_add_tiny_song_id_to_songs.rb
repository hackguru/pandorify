class AddTinySongIdToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :tiny_song_id, :string
  end
end
