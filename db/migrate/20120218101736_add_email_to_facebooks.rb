class AddEmailToFacebooks < ActiveRecord::Migration
  def change
    add_column :facebooks, :email, :text
  end
end
