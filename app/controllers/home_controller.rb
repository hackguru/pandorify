class HomeController < ApplicationController
  before_filter :require_authentication, :only => :play
  
  def index
  end

  #POST home/play
  def play
    identifiers = params[:friend_tokens].split(",")
    friend_list = current_user.profile.friends.reject {|item| !identifiers.include? item.identifier}
    common_artist = Hash.new
    friend_list.each do |friend|
      user = FbGraph::User.fetch(friend.identifier, :access_token => friend.access_token)
      user.music.each do |music|
        #if music.category == "Musician/band"
          if common_artist.has_key? music.name
            common_artist[music.name] += 1
          else
            common_artist[music.name] = 1
          end
        #end
      end  
    end
    
    current_user.music.each do |music|
      #if music.category == "Musician/band"
        if common_artist.has_key? music.name
          common_artist[music.name] += 1
        else
          common_artist[music.name] = 1
        end
      #end
    end
    
    sort_common_artists  = common_artist.sort_by {|key, values| -1*values}
    
    @tracklist = Array.new  
    sort_common_artists.take(30).each do |pair|
      c = Curl::Easy.perform("http://ws.spotify.com/search/1/track.json?q=#{CGI.escape pair[0].to_s}")
      parsed_json = ActiveSupport::JSON.decode(c.body_str)
      parsed_json['tracks'].each do |track|
        count = 0
        check = false
        @tracklist.each do |item|
          check = (item[0].downcase == track['name'].downcase)
          break if check
        end
        next if check
        @tracklist << [track['name'], "http://open.spotify.com/track/" + track['href'][14..track['href'].length]]
        count += 1
        break if count == 2**pair[1]-1
      end
    end

    @tracklist.each do |track|
      c = Curl::Easy.perform("http://tinysong.com/b/#{CGI.escape track[0].to_s.sub(" ","+")}?format=json&key=186bd60f3a33be26da02d62d334bddf4")
      parsed_json = ActiveSupport::JSON.decode(c.body_str)
      track << parsed_json['SongID']
    end
        
  	respond_to do |format|
       format.html # play.html.erb
    end

  end
  
end
