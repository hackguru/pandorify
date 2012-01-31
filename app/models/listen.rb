class Listen < ActiveRecord::Base
  belongs_to :facebook
  belongs_to :song
  
  scope :song_based_on_sorted_listens,
        :select => "#{Song.table_name}.*, count(#{Listen.table_name}.id) as listen_count",
        :joins => "LEFT JOIN #{Song.table_name} ON #{Listen.table_name}.song_id = #{Song.table_name}.id",
        :group => "#{Song.table_name}.id, #{Song.table_name}.identifier, #{Song.table_name}.title, #{Song.table_name}.url, #{Song.table_name}.created_at, #{Song.table_name}.updated_at, #{Song.table_name}.application_id, #{Song.table_name}.popularity, #{Song.table_name}.artist_id, #{Song.table_name}.album_id",
        :order => "listen_count DESC, #{Song.table_name}.popularity DESC"
        
  scope :song_based_on_sorted_listens_by_user,
        :select => "#{Song.table_name}.*, count(#{Facebook.table_name}.id) as user_count",
        :joins => "LEFT JOIN #{Song.table_name} ON #{Listen.table_name}.song_id = #{Song.table_name}.id",
        :joins => "LEFT JOIN #{Facebook.table_name} ON #{Listen.table_name}.user_id = #{Facebook.table_name}.id",
        :group => "#{Song.table_name}.id, #{Song.table_name}.identifier, #{Song.table_name}.title, #{Song.table_name}.url, #{Song.table_name}.created_at, #{Song.table_name}.updated_at, #{Song.table_name}.application_id, #{Song.table_name}.popularity, #{Song.table_name}.artist_id, #{Song.table_name}.album_id",
        :order => "user_count DESC, #{Song.table_name}.popularity DESC"
  
end
