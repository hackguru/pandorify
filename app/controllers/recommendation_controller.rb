class RecommendationController < ApplicationController
  include ApplicationHelper
  def recommended
    @page =  params[:page] || 1
    @from_friends = params[:from_friends] || str_to_bool(params[:from_friends]) || false
    if @from_friends
      @user = current_user || Facebook.find_by_email(params[:user_email])
    else
      @user = current_user
    end
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
