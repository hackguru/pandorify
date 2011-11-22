class AddNameToFacebooks < ActiveRecord::Migration
  def change
    add_column :facebooks, :name, :string
  end
end
