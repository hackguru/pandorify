class Facebook < ActiveRecord::Base
  has_many :subscriptions
  has_and_belongs_to_many :musics
  validates_uniqueness_of :identifier
  has_many :friendships, :foreign_key => :user_id, :dependent => :destroy
  has_many :reverse_friendships, :class_name => 'Friendship', :foreign_key => :friend_id, :dependent => :destroy
  has_many :friends, :through => :friendships, :source => :friend
  
  

  def profile
    @profile ||= FbGraph::User.me(self.access_token).fetch
  end

  def retrieve_music
    @music ||= FbGraph::User.me(self.access_token).fetch.music
  end
  
  def retrieve_music_activity (since = nil)
    new_data = []
    data = nil
    offset_limit = {:offset=>"0", :limit=>"100"}
    if since == nil
      begin
       data = FbGraph::User.me(self.access_token).og_actions "music.listens", offset_limit
       data.each do |listen|
         new_data << listen
       end
       offset_limit = data.collection.next
      end while data.count > 0
    else
      since_condition = true
      begin
       data = FbGraph::User.me(self.access_token).og_actions "music.listens", offset_limit
       data.each do |listen|
         if listen.publish_time >= since
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
      if _fb_user_.access_token != fb_user.identifier.try(:to_s)
        _fb_user_.access_token = fb_user.identifier.try(:to_s)
      end
      _fb_user_.name = fb_user.name
      _fb_user_.save!
      friends = current_user.friends #helps perf
      current_user.friends << _fb_user_ if !friends.include? _fb_user_
       _fb_user_    
    end
  end

end