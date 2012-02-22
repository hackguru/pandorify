class AddSongsPartiesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :songs_parties, :id => false do |t|
      t.integer :song_id
      t.integer :party_id
    end
  end

  def self.down
    drop_table :songs_parties
  end
end
