class AddingUniqueness < ActiveRecord::Migration
  def up
    add_index :facebooks, :identifier, :unique => true
    add_index :musics, :identifier, :unique => true
  end

  def down
  end
end
