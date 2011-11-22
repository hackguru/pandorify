class CreateMusics < ActiveRecord::Migration
  def change
    create_table :musics do |t|
      t.string :identifier
      t.string :access_token
      t.string :name
      t.string :category

      t.timestamps
    end
  end
end
