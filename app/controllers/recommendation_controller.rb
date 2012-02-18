class RecommendationController < ApplicationController

  def recommended
    @page =  params[:page] || 1
    @user = current_user
    @recoms = @user.recommendations.paginate(:page => @page ).find(:all,:conditions=>["listened is not true"], :order => "common_rank DESC")
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
