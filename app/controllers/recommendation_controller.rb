class RecommendationController < ApplicationController

  def recommended
    @page =  params[:page] || 1
    @recoms = current_user.recommendations.order("common_rank DESC").paginate(:page => @page )
    @type = params[:type] || "grid"
    @songs = []
    @recoms.each do |recom|
      @songs << recom.song
    end
    respond_to do |format|
       format.js
    end
  end

end
