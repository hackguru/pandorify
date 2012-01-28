class AddAccessTokenToListens < ActiveRecord::Migration
  def change
    add_column :listens, :access_token, :string
  end
end
