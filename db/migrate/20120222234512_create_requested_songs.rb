class CreateRequestedSongs < ActiveRecord::Migration
  def change
    create_table :requested_songs do |t|
      t.references :song
      t.references :party
      t.references :facebook
      t.boolean :added

      t.timestamps
    end
    add_index :requested_songs, :song_id
    add_index :requested_songs, :party_id
    add_index :requested_songs, :facebook_id
  end
end
