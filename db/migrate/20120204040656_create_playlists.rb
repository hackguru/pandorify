class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.string :name
      t.boolean :perm

      t.timestamps
    end
  end
end
