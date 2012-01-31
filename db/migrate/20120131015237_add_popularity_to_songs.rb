class AddPopularityToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :popularity, :float
  end
end
