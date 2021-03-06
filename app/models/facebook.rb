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
  has_many :requestedsongs, :dependent => :destroy
  has_many :recommendeds, :through => :recommendations, :source => :song
  # has_many :commended_songs_by_me, :foreign_key => :recommended_by_id, :through => :recommendations, :source => :song
  has_many :recommendations_because_of_me, :class_name => 'Recommendation', :foreign_key => :recommended_by_id
  has_many :playlists
  has_and_belongs_to_many :parties, :join_table => "facebooks_parties"
  has_many :hosted_parties, :foreign_key => :host_id, :class_name => 'Party'
  
  
  
  scope :users_listen_to, lambda { |song| {
        :select => "#{Facebook.table_name}.*, count(#{Listen.table_name}.id) as listen_count",
        :joins => "LEFT JOIN #{Listen.table_name} ON #{Facebook.table_name}.id = #{Listen.table_name}.facebook_id LEFT JOIN #{Song.table_name} ON #{Listen.table_name}.song_id = #{Song.table_name}.id AND #{Song.table_name}.id = #{song.id}",
        :conditions => ["#{Song.table_name}.id = ?", song.id],
        :group => "#{Facebook.table_name}.id, #{Facebook.table_name}.identifier, #{Facebook.table_name}.access_token, #{Facebook.table_name}.created_at, #{Facebook.table_name}.updated_at, #{Facebook.table_name}.is_friend_access, #{Facebook.table_name}.name, #{Facebook.table_name}.last_updated, #{Facebook.table_name}.pic_url, #{Facebook.table_name}.email, #{Facebook.table_name}.cell",
        :order => "count(#{Listen.table_name}.id) DESC"
  }}

  scope :users_with_common_song, lambda { |user| {
        :select => "friends.*, count(distinct #{Song.table_name}.id) as song_count",
        :from => "#{Facebook.table_name} as friends",
        :joins => "LEFT JOIN #{Listen.table_name} as friendlistens ON friends.id = friendlistens.facebook_id LEFT JOIN #{Song.table_name} ON friendlistens.song_id = #{Song.table_name}.id LEFT JOIN #{Listen.table_name} as userlistens ON #{Song.table_name}.id = userlistens.song_id LEFT JOIN #{Facebook.table_name} as users ON userlistens.facebook_id = users.id  AND users.id = #{user.id} AND friends.id <> #{user.id}",
        :conditions => ["users.id = ?", user.id],
        :group => "friends.id, friends.identifier, friends.access_token, friends.created_at, friends.updated_at, friends.is_friend_access, friends.name, friends.last_updated, friends.pic_url, friends.email, friends.cell",
        :order => "count(distinct #{Song.table_name}.id) DESC"
  }}

  scope :users_with_common_song_among_friends, lambda { |user| {
        :select => "friends.*, count(distinct #{Song.table_name}.id) as song_count",
        :from => "#{Facebook.table_name} as friends",
        :joins => "INNER JOIN friendships ON friends.id = friendships.friend_id LEFT JOIN #{Listen.table_name} as friendlistens ON friends.id = friendlistens.facebook_id LEFT JOIN #{Song.table_name} ON friendlistens.song_id = #{Song.table_name}.id LEFT JOIN #{Listen.table_name} as userlistens ON #{Song.table_name}.id = userlistens.song_id LEFT JOIN #{Facebook.table_name} as users ON userlistens.facebook_id = users.id  AND users.id = #{user.id} AND friends.id <> #{user.id} AND friendships.user_id = users.id",
        :conditions => ["users.id = ?", user.id],
        :group => "friends.id, friends.identifier, friends.access_token, friends.created_at, friends.updated_at, friends.is_friend_access, friends.name, friends.last_updated, friends.pic_url, friends.email, friends.cell",
        :order => "count(distinct #{Song.table_name}.id) DESC"
  }}

  def profile
    @profile ||= FbGraph::User.fetch(self.identifier, :access_token => self.access_token)
  end

  def retrieve_music
    @music ||= FbGraph::User.fetch(self.identifier, :access_token => self.access_token).fetch.music
  end
  
  
  def update_pic
    if self.pic_url == nil
      begin
        user = FbGraph::User.fetch(self.identifier, :access_token => self.access_token)
        self.pic_url =user.picture
        self.save!
        # cleaning up
        user = nil
        GC.start # Run the garbage collector to be sure this is real !        
      rescue
        return
      end
    end
  end
  
  def retrieve_music_activity (since = nil)
    new_data = []
    begin
      user = FbGraph::User.fetch(self.identifier, :access_token => self.access_token)
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
    rescue
      return new_data
    end
    new_data
  end

  def add_music_activity
    if self.last_updated == nil
      music_activity = self.retrieve_music_activity
    else
      music_activity = self.retrieve_music_activity self.last_updated
    end

    music_activity.each do |object|
      begin
        new_application = Application.find_or_create_by_identifier(object.raw_attributes["application"]["id"])
        new_application.name = object.raw_attributes["application"]["name"]
        new_application.save!
      
        new_song = Song.find_or_create_by_identifier(object.raw_attributes["data"]["song"]["id"])
        new_song.title = object.raw_attributes["data"]["song"]["title"][0..254] #only the first characters - might wanna change this later to text
        new_song.url = object.raw_attributes["data"]["song"]["url"][0..254] #only the first characters - might wanna change this later to text
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

        # cleaning up
        new_application = nil
        new_song = nil
        new_listen = nil
        GC.start # Run the garbage collector to be sure this is real !        
      rescue
        next
      end
      
      # cleaning up
      music_activity = nil
      GC.start # Run the garbage collector to be sure this is real !
      
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
        # begin
          Facebook.add_as_friend friend, self
        # rescue
          # next
        # end
      end
      # cleaning up
      friend_list = nil
      GC.start # Run the garbage collector to be sure this is real !
    end    
  end
  
  def update_me
    time_for_update = Time.now
    self.add_friends
    self.add_music_activity
    self.update_pic
    self.last_updated = time_for_update
    self.save!
    # cleaning up
    time_for_update = nil
    GC.start # Run the garbage collector to be sure this is real !
  end
  
  
  def update_recommendations
    
    # removing listended recommendations
    self.recommendations.all.each do |recom|
      if self.songs.include? recom.song
        recom.listened = true
        recom.save!
      end
    end
    
    # this can be done with friends
    list = Facebook.users_with_common_song(self).limit(50) #for better perf (limit 50)
    sum = 0
    list.each do |obj|
      sum += obj.song_count.to_i
    end
    
    if sum == 0
      return
    end
    
    list.each do |obj|
      number_of_songs = (obj.song_count.to_f/sum.to_f*20.0).round
      list_of_songs = Song.song_based_on_sorted_listens_for_user_that_are_not_common_with_the_other(obj,self).limit(20) #for better perf (limit 20)
      list_of_songs.each do |song|
        break if number_of_songs == 0
        recom = Recommendation.find_or_initialize_by_song_id_and_facebook_id(song.id, self.id)
        if (recom.listened == true)
          next           
        end
        recom.facebook = self
        recom.common_rank = obj.song_count.to_i
        recom.recommended_by = obj
        recom.listened = false
        recom.save!
        number_of_songs -= 1
      end
    end    
  end
  
  def perform
    begin
      self.update_me
      self.update_recommendations if !self.is_friend_access
    rescue
      return
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
      _fb_user_.pic_url = fb_user.picture
      _fb_user_.email = fb_user.email
      pers = false
      if _fb_user_.persisted?
        pers = true
      end
      # getting data if the user is new
      if !pers
        Delayed::Job.enqueue _fb_user_
      end
      _fb_user_.save!
      if _fb_user_.playlists.find_by_name("Queue") == nil
        queue_pl = Playlist.create(:name => 'Queue', :facebook => _fb_user_, :perm => true)
        queue_pl.save!
      end
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
        _fb_user_.pic_url = fb_user.picture
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
      Facebook.find_each do |user|
        Delayed::Job.enqueue user
      end
      #updatinf frienads and songs
      # Facebook.all.each do |user|
      #   user.update_me
      # end
      #updating recommendations:
      # Facebook.find(:all,:conditions => ["is_friend_access = ?", false]).each do |user|
      #   user.update_recommendations
      # end
    end
    
    def create_queue_for_users
      Facebook.find(:all, :conditions => ["is_friend_access = ?", false]).each do |user|
        queue = user.playlists.find_or_create_by_name("Queue")
        queue.perm = true
        queue.save!
      end
    end
    
    def perform
      self.update_all
    end
    
  end

end