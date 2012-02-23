class CreateRequestedsongs < ActiveRecord::Migration
  def change
    create_table :requestedsongs do |t|
      t.references :facebook
      t.references :song
      t.references :party
      t.boolean :added

      t.timestamps
    end
    add_index :requestedsongs, :facebook_id
    add_index :requestedsongs, :song_id
    add_index :requestedsongs, :party_id
  end
end
