class AddEnergyToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :energy, :float
  end
end
