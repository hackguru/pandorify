class AddTempToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :temp, :text

    Song.reset_column_information
    Song.find_each { |s| s.update_attribute(:temp, c.title) }

  end
end
