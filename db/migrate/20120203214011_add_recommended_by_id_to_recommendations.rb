class AddRecommendedByIdToRecommendations < ActiveRecord::Migration
  def change
    add_column :recommendations, :recommended_by_id, :integer
  end
end
