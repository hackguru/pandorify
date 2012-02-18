class AddCellToFacebooks < ActiveRecord::Migration
  def change
    add_column :facebooks, :cell, :string
  end
end
