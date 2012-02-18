class AddListenedToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :bool, :listened
  end
end
