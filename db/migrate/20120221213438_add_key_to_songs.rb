class AddKeyToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :key, :integer
  end
end
