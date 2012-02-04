class AddCoverPicUrlToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :cover_pic_url, :text
  end
end
