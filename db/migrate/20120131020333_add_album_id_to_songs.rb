class AddAlbumIdToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :album_id, :ineteger
  end
end
