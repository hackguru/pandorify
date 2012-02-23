class PartyController < ApplicationController

  def create_or_more_songs
    if current_user
      @host = current_user
    elsif params[:host]
      @host = Facebook.find(params[:host])
    elsif
      @host = Facebook.find_by_email(params[:host_email])
    end
    
    ids = []
    params[:friend_tokens].split(",").map {|item| ids << item.to_i }
    ids_string = "("
    i = 0
    while i < ids.size() - 1
      ids_string += "#{Facebook.table_name}.id = #{ids[i]} OR "
      i += 1
    end
    ids_string += "#{Facebook.table_name}.id = #{ids[i]})"
    @page =  params[:page] || 1
    @songs = Song.sort_based_on_common_song_count(ids_string).paginate(:page => @page )

    @party = Party.find_or_initialize_by_host_id(@host.id);
    if !@party.persisted?
      @party.facebooks = ids
    else
      @party.songs = Requestedsongs.find(:all, :conditions => ['part_id = ? AND added = ?', @party.id, false])
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
  
  def update
  end
  
end
