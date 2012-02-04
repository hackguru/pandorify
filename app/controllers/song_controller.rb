class SongController < ApplicationController

  def hot_songs
    @page =  params[:page] || 1
    @after = params[:after] || 2.years.ago
    @songs = Song.song_based_on_sorted_listens_by_friends_after(current_user,@after).paginate(:page => @page )
    respond_to do |format|
       format.js
    end
  end
  
end
