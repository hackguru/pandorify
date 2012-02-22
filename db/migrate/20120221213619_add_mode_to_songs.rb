class AddModeToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :mode, :integer
  end
end
