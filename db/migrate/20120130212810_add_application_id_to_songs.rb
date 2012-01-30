class AddApplicationIdToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :application_id, :integer
  end
end
