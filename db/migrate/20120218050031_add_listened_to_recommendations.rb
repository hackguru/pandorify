class AddListenedToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :boolean, :listened
  end
end
