class TinySongController < ApplicationController
  
  def get_id
    obj = Song.find(params[:id])
    c = Curl::Easy.perform("http://tinysong.com/b/#{CGI.escape(obj.title.to_s + ' ' + obj.artist.name.to_s)}?format=json&key=96a8868b78efe9fdc0c23393f8ef6651") # FROM Tinysong
    parsed_json = ActiveSupport::JSON.decode(c.body_str)
    @id = parsed_json['SongID'].to_s if parsed_json['SongID'].to_s.size != 0
    
    respond_to do |format|
       format.js
    end
  end
  
end
