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

  def music
    @music ||= FbGraph::User.me(self.access_token).fetch.music
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
      _fb_user_ = find_or_initialize_by_identifier(fb_user.identifier.try(:to_s))
      _fb_user_.access_token = fb_user.access_token
      _fb_user_.name = fb_user.name
      _fb_user_.is_friend_access = true
      _fb_user_.save!
      friends = current_user.friends #helps perf
      current_user.friends << _fb_user_ if !friends.include? _fb_user_
      _fb_user_    
    end
  end

end