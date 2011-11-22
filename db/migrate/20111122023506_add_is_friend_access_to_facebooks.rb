class AddIsFriendAccessToFacebooks < ActiveRecord::Migration
  def up
    add_column :facebooks, :is_friend_access, :boolean
  end
  
  def down
    remove_column :facebooks, :is_friend_access
  end
end
