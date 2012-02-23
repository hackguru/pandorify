class SongController < ApplicationController

  def hot_songs
    @page =  params[:page] || 1
    @after = params[:after] || 2.days.ago
    @type = params[:type] || "grid"
    @from_friends = params[:from_friends] || str_to_bool(params[:from_friends]) || false
    if @from_friends
      @user = current_user || Facebook.find_by_email(params[:user_email])
      @songs = Song.song_based_on_sorted_listens_by_friends_after(@user,@after).paginate(:page => @page )
    end
    @songs = Song.song_based_on_sorted_listens_by_user_since(@after).paginate(:page => @page )
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
  
  def party
    ids = params[:friend_tokens].split(",")
    ids_string = "("
    i = 0
    while i < ids.size() - 1
      ids_string += "#{Facebook.table_name}.id = #{ids[i]} OR "
      i += 1
    end
    ids_string += "#{Facebook.table_name}.id = #{ids[i]})"
      
    @page =  params[:page] || 1
    @after = params[:after] || 2.years.ago
    @type = params[:type] || "grid"
    @songs = Song.sort_based_on_common_song_count(ids_string).paginate(:page => @page )
    respond_to do |format|
       format.js
       format.json{
         render :json => @songs.to_json
       }
    end
  end
  
  private
  
  def str_to_bool (arg)
    return true if arg == true || arg =~ (/(true|t|yes|y|1)$/i)
    return false if arg == false || arg.blank? || arg =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{arg}\"")
  end
  
end
