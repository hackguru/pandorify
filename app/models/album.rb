class Album < ActiveRecord::Base
  has_many :songs
  
  def update_album_cover
    c = Curl::Easy.perform(self.url)
    tag = c.body_str.match /<img id=\"cover-art\" src=\".*\"/
    link = tag[0][25..tag[0].size]
    link = link[0..link.size-2]
    self.cover_pic_url = link
    self.save!
  end
  
end
