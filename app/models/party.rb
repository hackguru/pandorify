class Party < ActiveRecord::Base
  has_and_belongs_to_many :facebooks, :join_table => "facebooks_parties"
  has_and_belongs_to_many :songs, :join_table => "songs_parties"
end
