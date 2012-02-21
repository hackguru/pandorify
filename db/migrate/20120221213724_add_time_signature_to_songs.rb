class AddTimeSignatureToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :time_signature, :integer
  end
end
