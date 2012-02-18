class AddListenedToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :listened, :boolean
  end
end
