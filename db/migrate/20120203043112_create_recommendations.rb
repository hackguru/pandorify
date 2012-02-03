class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.integer :facebook_id
      t.integer :song_id
      t.integer :common_rank

      t.timestamps
    end
  end
end
