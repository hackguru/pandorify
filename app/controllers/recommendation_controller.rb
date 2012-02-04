class RecommendationController < ApplicationController

  def recommended
    @page =  params[:page] || 1
    @recoms = current_user.recommendations.paginate(:page => @page )
    @songs = []
    @recoms.each do |recom|
      @songs << recom.song
    end
    respond_to do |format|
       format.js
    end
  end

end
