class PartyController < ApplicationController
  include ApplicationHelper

  def index
    
    @tempo_min = params[:tempo_min] || 0.0
    @tempo_max = params[:tempo_max] || 300.0
    @danceability_min = params[:danceability_min] || 0.0
    @danceability_max = params[:danceability_max] || 1.0
    @energy_min = params[:energy_min] || 0.0
    @energy_max = params[:energy_max] || 1.0
    @loudness_min = params[:loudness_min] || -100.0
    @loudness_max = params[:loudness_max] || 1.0
    
    if current_user
      @host = current_user
    elsif params[:host]
      @host = Facebook.find(params[:host])
    elsif
      @host = Facebook.find_by_email(params[:host_email])
    end
    
    ids = params[:friend_tokens].split(",")
    ids_string = "("
    i = 0
    while i < ids.size() - 1
      ids_string += "#{Facebook.table_name}.id = #{ids[i]} OR "
      i += 1
    end
    ids_string += "#{Facebook.table_name}.id = #{ids[i]})"
    @page =  params[:page] || 1
    @songs = Song.sort_based_on_common_song_count(ids_string).songs_with_tempo_range(@tempo_min,@tempo_max).songs_with_danceability_range(@danceability_min,@danceability_max).songs_with_energy_range(@energy_min,@energy_max).songs_with_loudness_range(@loudness_min,@loudness_max).paginate(:page => @page )

    @party = Party.find_or_initialize_by_host_id(@host.id);
    @party.facebooks = Facebook.find(:all,:conditions=>[ids_string])
    Requestedsong.find(:all, :conditions => ['party_id = ? AND added = ?', @party.id, false]).each do |request|
      @party.songs << request.song
      request.added = true
      request.save
    end
    @party.save
      
        
      
    @type = params[:type] || "grid"

    respond_to do |format|
       format.js
       format.json{
         render :json => {:matched => @songs.to_json, :requested => @party.songs}
       }
    end
  end
  
end
