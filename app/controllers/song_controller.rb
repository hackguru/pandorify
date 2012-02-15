class SongController < ApplicationController

  def hot_songs
    @page =  params[:page] || 1
    @after = params[:after] || 2.years.ago
    @type = params[:type] || "grid"
    @songs = Song.song_based_on_sorted_listens_by_friends_after(current_user,@after).paginate(:page => @page )
    respond_to do |format|
       format.js
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
    d = Facebook.find_by_name("Eddie Simmens").id
    g = Facebook.find_by_name("Gabe Audick").id
    e = Facebook.find_by_name("Edward Mehr").id
    @page =  params[:page] || 1
    @after = params[:after] || 2.years.ago
    @type = params[:type] || "grid"
    @songs = Song.sort_based_on_common_song_count("(#{Facebook.table_name}.id = #{e} OR #{Facebook.table_name}.id = #{g} OR #{Facebook.table_name}.id = #{d})").paginate(:page => @page )
    respond_to do |format|
       format.js
    end
  end
  
  
end
