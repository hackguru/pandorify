class AddPicUrlToFacebooks < ActiveRecord::Migration
  def change
    add_column :facebooks, :pic_url, :text
  end
end
