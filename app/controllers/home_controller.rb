class HomeController < ApplicationController
  include ApplicationHelper
  before_filter :require_authentication, :only => :play
  
  def index
    if authenticated?
      @page =  params[:page] || 1
      @after = params[:after] || 2.days.ago
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
      @playlists =  @songs.playlists
      respond_to do |format|
        format.html
         format.js
         format.json{
           render :json => @songs.to_json
         }
      end
    end
  end

  def new
    if authenticated?
      @music = current_user.retrieve_music_activity 2.days.ago
    end    
  end
  
  #POST home/play
  def play
    identifiers = params[:friend_tokens].split(",")
    friend_list = current_user.friends.reject {|item| !identifiers.include? item.identifier}
    common_artist = Hash.new
    friend_list.each do |friend|
      user = FbGraph::User.fetch(friend.identifier, :access_token => friend.access_token)
      user.retrieve_music.each do |music|
        #if music.category == "Musician/band"
          if common_artist.has_key? music.name
            common_artist[music.name] += 1
          else
            common_artist[music.name] = 1
          end
        #end
      end  
    end
    
    current_user.retrieve_music.each do |music|
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
    counter = 0
    sort_common_artists.take(30).each do |pair|
      begin
        # c = Curl::Easy.perform("http://ws.spotify.com/search/1/track.json?q=#{CGI.escape pair[0].to_s}") # FROM SPOTIFY 
        c = Curl::Easy.perform("http://tinysong.com/s/#{CGI.escape pair[0].to_s.sub(" ","+")}?format=json&limit=#{[32,2**pair[1]-1].min}&key=186bd60f3a33be26da02d62d334bddf4") # FROM Tinysong      
      rescue
        next
      end
      parsed_json = ActiveSupport::JSON.decode(c.body_str)
      # parsed_json['tracks'].each do |track| # FOR SPOTIFY
      parsed_json.each do |track| # FOR TINYSONG
        # count = 0 # FOR SPOTIFY
        check = false
        @tracklist.each do |item|
          check = (item[0].downcase == track['SongName'].downcase)
          break if check
        end
        next if check
        # @tracklist << [track['name'], "http://open.spotify.com/track/" + track['href'][14..track['href'].length]] # FOR SPOTIFY
        @tracklist << [track['SongName'], track['ArtistName'], track['Url'], track['SongID']] # FOR TINYSONG
        counter += 1
        break if counter == 30
        # count += 1 # FOR SPOTIFY
        # break if count == 2**pair[1]-1 # FOR SPOTIFY
      end
      break if counter == 30
    end

    # @tracklist.each do |track| # FOR SPOTIFY
    #     begin
    #       c = Curl::Easy.perform("http://tinysong.com/b/#{CGI.escape track[0].to_s.sub(" ","+")}?format=json&key=186bd60f3a33be26da02d62d334bddf4") # FOR SPOTIFY
    #     rescue
    #       next
    #     end
    #   parsed_json = ActiveSupport::JSON.decode(c.body_str) # FOR SPOTIFY
    #   track << parsed_json['SongID'] # FOR SPOTIFY
    # end # FOR SPOTIFY
        
    
  	respond_to do |format|
       format.html # play.html.erb
    end

  end
  
end
