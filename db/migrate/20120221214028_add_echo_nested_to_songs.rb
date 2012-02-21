class AddEchoNestedToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :echo_nested, :boolean
  end
end
