class SongController < ApplicationController
  include ApplicationHelper

  def hot_songs
    @page =  params[:page] || 1
    @after = params[:after] || 5.days.ago
    @type = params[:type] || "grid"
    @tempo_min = params[:tempo_min] || 0.0
    @tempo_max = params[:tempo_max] || 300.0
    @danceability_min = params[:danceability_min] || 0.0
    @danceability_max = params[:danceability_max] || 1.0
    @energy_min = params[:energy_min] || 0.0
    @energy_max = params[:energy_max] || 1.0
    @loudness_min = params[:loudness_min] || -100.0
    @loudness_max = params[:loudness_max] || 1.0
    @from_friends = params[:from_friends] || str_to_bool(params[:from_friends]) || false
    if @from_friends
      @user = current_user || Facebook.find_by_email(params[:user_email])
      @songs = Song.song_based_on_sorted_listens_by_friends_after(@user,@after).songs_with_tempo_range(@tempo_min,@tempo_max).songs_with_danceability_range(@danceability_min,@danceability_max).songs_with_energy_range(@energy_min,@energy_max).songs_with_loudness_range(@loudness_min,@loudness_max).paginate(:page => @page )
    else
      @songs = Song.song_based_on_sorted_listens_by_user_since(@after).songs_with_tempo_range(@tempo_min,@tempo_max).songs_with_danceability_range(@danceability_min,@danceability_max).songs_with_energy_range(@energy_min,@energy_max).songs_with_loudness_range(@loudness_min,@loudness_max).paginate(:page => @page )
    end
    respond_to do |format|
       format.js
       format.json{
         render :json => @songs.to_json
       }
    end
  end
  
  def play
    obj = Song.find(params[:id])
    if obj.tiny_song == nil
      c = Curl::Easy.perform("http://tinysong.com/b/#{CGI.escape(obj.title.to_s + ' ' + obj.artist.name.to_s)}?format=json&key=96a8868b78efe9fdc0c23393f8ef6651") # FROM Tinysong
      parsed_json = ActiveSupport::JSON.decode(c.body_str)
      @id = parsed_json['SongID'].to_s if parsed_json['SongID'].to_s.size != 0
      obj.tiny_song = @id
      obj.save!
    else
      @id = obj.tiny_song
    end
    pl = current_user.playlists.find_by_name("Queue")
    pl.songs << obj
    pl.save!
    respond_to do |format|
       format.js
    end
  end
      
end
