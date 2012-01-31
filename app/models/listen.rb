class Listen < ActiveRecord::Base
  belongs_to :facebook
  belongs_to :song
  
  scope :sorted_based_on_song,
        :select => "#{Song.table_name}.id, count(#{Listen.table_name}.id) as listen_count",
        :joins => "LEFT JOIN #{Song.table_name} ON #{Listen.table_name}.song_id = #{Song.table_name}.id",
        :group => "#{Song.table_name}.id",
        :order => "listen_count DESC"  
end
