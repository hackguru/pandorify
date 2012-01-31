class Listen < ActiveRecord::Base
  belongs_to :facebook
  belongs_to :song
  
  scope :sorted_based_on_song,
        :select => "#{Song.table_name}.*, count(id) as listen_count",
        :group => "song_id",
        :order => "listen_count DESC"  
end
