class AddIsFriendAccessToFacebooks < ActiveRecord::Migration
  def up
    add_column :facebooks, :is_friend_access, :boolean
    Facebook.find(:all).each do |f|
      f.update_attribute :is_friend_access, false
    end
  end
  
  def down
    remove_column :facebooks, :is_friend_access
  end
end
