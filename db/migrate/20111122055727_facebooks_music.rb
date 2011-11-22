class FacebooksMusic < ActiveRecord::Migration
  def up
    create_table "facebooks_musics", :id => false do |t|
      t.column "facebook_id", :integer, :null => false
      t.column "music_id",  :integer, :null => false
    end
  end

  def down
    drop_table :facebooks_musics
  end
end
