class HomeController < ApplicationController
  before_filter :require_authentication, :only => :play
  
  def index
  end

  #POST home/play
  def play
    identifiers = params[:friend_tokens].split(",")
    friend_list = current_user.profile.friends.reject {|item| !identifiers.include? item.identifier}
    @common_artist = Hash.new
    friend_list.each do |friend|
      user = FbGraph::User.fetch(friend.identifier, :access_token => friend.access_token)
      user.music.each do |music|
        #if music.category == "Musician/band"
          if @common_artist.has_key? music.name
            @common_artist[music.name] += 1
          else
            @common_artist[music.name] = 1
          end
        #end
      end  
    end
    @sort_common_artists  = @common_artist.sort_by {|key, values| -1*values}
      
    

  	respond_to do |format|
       format.html # play.html.erb
    end

  end
  
end
