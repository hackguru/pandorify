class Album < ActiveRecord::Base
  has_many :songs
  
  def update_album_cover
    c = Curl::Easy.perform(self.url)
    tag = c.body_str.match /<img id=\"cover-art\" src=\".*\"/
    link = tag[0][25..tag[0].size]
    link = link[0..link.size-2]
    self.cover_pic_url = link
    self.save!
    # cleaning up
    c = nil
    tag = nil
    link = nil
    GC.start # Run the garbage collector to be sure this is real !    
  end
  
  def perform
    begin
      self.update_album_cover
    rescue
      return
    end
  end
  
  class << self
    extend ActiveSupport::Memoizable
  
    def update_all_covers
      Album.find_each(:conditions => ["cover_pic_url is null"]) do |obj|
        # begin
          Delayed::Job.enqueue obj
        # rescue
          # next
        # end
      end
    end
    
    def perform
      self.update_all_covers
    end
    
  end
  
end
