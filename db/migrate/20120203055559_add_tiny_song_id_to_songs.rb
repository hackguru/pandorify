class AddTinySongIdToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :tiny_song, :string
  end
end
