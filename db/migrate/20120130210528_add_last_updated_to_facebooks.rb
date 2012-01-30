class AddLastUpdatedToFacebooks < ActiveRecord::Migration
  def change
    add_column :facebooks, :last_updated, :datetime
  end
end
