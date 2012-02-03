class Facebook < ActiveRecord::Base
  has_many :subscriptions
  has_and_belongs_to_many :musics
  validates_uniqueness_of :identifier
  has_many :friendships, :foreign_key => :user_id, :dependent => :destroy
  has_many :reverse_friendships, :class_name => 'Friendship', :foreign_key => :friend_id, :dependent => :destroy
  has_many :friends, :through => :friendships, :source => :friend
  has_many :listens
  has_many :songs, :through => :listens, :source => :song
  has_many :recommendations, :dependent => :destroy
  has_many :recommendeds, :through => :recommendations, :source => :song
  
  

  def profile
    @profile ||= FbGraph::User.fetch(self.identifier, :access_token => self.access_token)
  end

  def retrieve_music
    @music ||= FbGraph::User.fetch(self.identifier, :access_token => self.access_token).fetch.music
  end
  
  def retrieve_music_activity (since = nil)
    new_data = []
    begin
      user = FbGraph::User.fetch(self.identifier, :access_token => self.access_token)
    rescue
      return new_data
    end
    data = nil
    offset_limit = {:offset=>"0", :limit=>"100"}
    since_condition = true
    if since == nil
      begin
       begin
         data = user.og_actions "music.listens", offset_limit
       rescue
         break
       end
       data.each do |listen|
         if listen != nil
           new_data << listen
         else
           since_condition = false
           break
         end
       end
       offset_limit = data.collection.next
      end while data.count > 0 and since_condition
    else
      begin
        begin
          data = user.og_actions "music.listens", offset_limit
        rescue
          break
        end
       data.each do |listen|
         if listen.publish_time.utc >= since.utc and listen != nil
           new_data << listen
         else
           since_condition = false
           break
         end
       end
       offset_limit = data.collection.next
      end while data.count > 0 and since_condition
    end
    new_data
    
    # url = "https://graph.facebook.com/#{self.identifier}/music.listens?access_token=#{self.access_token}"
    # @music_activity = []
    # new_data = []
    # count = 5
    # begin
    #   uri = URI.parse(url)
    #   http = Net::HTTP.new(uri.host, uri.port)
    #   http.use_ssl = true
    #   http.verify_mode = OpenSSL::SSL::VERIFY_PEER 
    #   http.ca_file = '/usr/lib/ssl/certs/ca-certificates.crt'
    #   request = Net::HTTP::Get.new(uri.request_uri)
    #   response = http.request(request).body
    #   new_info = JSON.parse(response)
    #   url = new_info['paging']['next']
    #   new_data = new_info['data']
    #   @music_activity.push new_data
    #   count -= 1
    # end while new_data.count > 0 and count > 0
    # @music_activity
  end

  def add_music_activity
    if self.last_updated == nil
      music_activity = self.retrieve_music_activity
    else
      music_activity = self.retrieve_music_activity self.last_updated
    end

    music_activity.each do |object|
      
      new_application = Application.find_or_create_by_identifier(object.raw_attributes["application"]["id"])
      new_application.name = object.raw_attributes["application"]["name"]
      new_application.save!
      
      new_song = Song.find_or_create_by_identifier(object.raw_attributes["data"]["song"]["id"])
      new_song.title = object.raw_attributes["data"]["song"]["title"]
      new_song.url = object.raw_attributes["data"]["song"]["url"]
      new_song.application_id = new_application 
      new_song.save!
      
      new_listen = Listen.find_or_create_by_identifier(object.raw_attributes["id"])
      new_listen.facebook = self
      new_listen.start_time = object.start_time
      new_listen.end_time = object.end_time
      new_listen.publish_time = object.publish_time
      new_listen.song = new_song
      new_listen.access_token = object.raw_attributes["access_token"]
      new_listen.save!
      
    end
    
  end           
  
  def add_friends
    if !self.is_friend_access
      begin
        friend_list = self.profile.friends
      rescue
        return
      end
      friend_list.each do |friend|
        begin
          Facebook.add_as_friend friend, self
        rescue
          next
        end
      end
    end    
  end
  
  def update_me
    time_for_update = Time.now
    self.add_friends
    self.add_music_activity
    self.last_updated = time_for_update
    self.save!
  end
  
  def list_of_friends_with_most_in_common
    result = []
    self.friends.each do |fri|
      begin
        common_list = Song.common_songs self,fri
        size = 0
        common_list.each do |obj|
          size += 1
        end
        result << [fri, size]
      rescue
        next
      end
    end
    result.sort! { |a,b| -a[1] <=> -b[1] }
    result
  end
  
  def update_recommendations
    list = self.list_of_friends_with_most_in_common
    sum = 0
    list.each do |obj|
      break if obj[1] == 0
      sum += obj[1]
    end
    
    if sum == 0
      return
    end
    
    list.each do |obj|
      break if obj[1] == 0      
      number_of_songs = (obj[1]/sum).to_i
      list_of_songs = Song.song_based_on_sorted_listens_by_user(obj[0])
      list_of_songs.each do |song|
        break if number_of_songs == 0
        if self.songs.include? song
          next
        else
          recom = Recommendation.create(:facebook => self, :song => song, :common_rank => obj[1])
          recom.save!
          number_of_songs -= 0
        end
      end
    end
    
  end
  
  class << self
    extend ActiveSupport::Memoizable

    def config
      @config ||= if ENV['fb_client_id'] && ENV['fb_client_secret'] && ENV['fb_scope'] && ENV['fb_canvas_url']
        {
          :client_id     => ENV['fb_client_id'],
          :client_secret => ENV['fb_client_secret'],
          :scope         => ENV['fb_scope'],
          :canvas_url    => ENV['fb_canvas_url']
        }
      else
        YAML.load_file("#{Rails.root}/config/facebook.yml")[Rails.env].symbolize_keys
      end
    rescue Errno::ENOENT => e
      raise StandardError.new("config/facebook.yml could not be loaded.")
    end

    def app
      FbGraph::Application.new config[:client_id], :secret => config[:client_secret]
    end

    def auth(redirect_uri = nil)
      FbGraph::Auth.new config[:client_id], config[:client_secret], :redirect_uri => redirect_uri
    end

    def identify(fb_user)
      _fb_user_ = find_or_initialize_by_identifier(fb_user.identifier.try(:to_s))
      _fb_user_.access_token = fb_user.access_token.access_token #why two access_token?
      _fb_user_.name = fb_user.name
      _fb_user_.is_friend_access = false
      _fb_user_.save!
      _fb_user_
    end
    
    def add_as_friend(fb_user, current_user)
      _fb_user_ = nil
      _fb_user_ = where(:identifier => fb_user.identifier.try(:to_s)).first
      if _fb_user_ == nil
        _fb_user_ = Facebook.new
        _fb_user_.identifier = fb_user.identifier.try(:to_s)
        _fb_user_.access_token = fb_user.access_token
        _fb_user_.is_friend_access = true
      end
      if _fb_user_.access_token != fb_user.access_token.try(:to_s)
        _fb_user_.access_token = fb_user.access_token.try(:to_s)
      end
      _fb_user_.name = fb_user.name
      _fb_user_.save!
      friends = current_user.friends #helps perf
      current_user.friends << _fb_user_ if !friends.include? _fb_user_
       _fb_user_    
    end
    
    def update_all
      Facebook.all.each do |user|
        user.update_me
      end
    end
    
  end

end