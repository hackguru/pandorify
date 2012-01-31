class Listen < ActiveRecord::Base
  belongs_to :facebook
  belongs_to :song
  
  scope :sorted_based_on_song,
        :select => "#{Song.table_name}.id, count(#{Listen.table_name}.id) as listen_count",
        :joins => "LEFT JOIN #{Song.table_name} ON #{Song.table_name}.id = #{Listen.table_name}.song_id",
        :group => "#{Listen.table_name}.song_id",
        :order => "listen_count DESC"  
end
