class AddFacebookIdToPlaylists < ActiveRecord::Migration
  def change
    add_column :playlists, :facebook_id, :integer
  end
end
