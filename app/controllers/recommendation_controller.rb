class RecommendationController < ApplicationController

  def recommended
    @page =  params[:page] || 1
    @songs = current_user.recommendations.paginate(:page => @page )
    respond_to do |format|
       format.js
    end
  end

end
