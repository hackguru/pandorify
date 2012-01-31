class Listen < ActiveRecord::Base
  belongs_to :facebook
  belongs_to :song
  
  scope :sorted_based_on_song,
        :select => "#{Song.table_name}.*, count(#{Listen.table_name}.id) as listen_count",
        :group => "#{Listen.table_name}.song_id",
        :order => "listen_count DESC"  
end
