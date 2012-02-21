class AddLastEchoNestedToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :last_echo_nested, :datetime
  end
end
