class DeleteSongsParties < ActiveRecord::Migration
  def up
    drop_table "songs_parties"
  end

  def down
    create_table :songs_parties, :id => false do |t|
      t.integer :song_id
      t.integer :party_id
    end
  end
end
