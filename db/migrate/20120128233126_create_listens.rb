class CreateListens < ActiveRecord::Migration
  def change
    create_table :listens do |t|
      t.string :identifier
      t.references :facebook
      t.datetime :start_time
      t.datetime :end_time
      t.datetime :publish_time
      t.references :song

      t.timestamps
    end
    add_index :listens, :facebook_id
    add_index :listens, :song_id
  end
end
