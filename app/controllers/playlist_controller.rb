class PlaylistController < ApplicationController
  
  def create
    @playlist = Playlist.create(:name => params[:plname], :perm => false, :facebook => current_user)
    @playlist.save!
    respond_to do |format|
       format.js
    end
  end
  
  def add
    @playlist = Playlist.find(params[:plid])
    @song = Song.find(params[:sid])
    @playlist.songs << @song
    respond_to do |format|
       format.js
    end
  end
  
  def create_and_add
    @playlist = Playlist.create(:name => params[:plname], :perm => false, :facebook => current_user)
    @playlist.save!
    @song = Song.find(params[:sid])
    @playlist.songs << @song
    respond_to do |format|
       format.js
    end
  end
  
end
