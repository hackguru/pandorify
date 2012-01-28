class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :identifier
      t.string :title
      t.string :url

      t.timestamps
    end
  end
end
