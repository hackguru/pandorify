class Party < ActiveRecord::Base
  has_and_belongs_to_many :facebooks, :join_table => "facebooks_parties"
  has_and_belongs_to_many :songs, :join_table => "songs_parties"
  belongs_to :host, :foreign_key => :host_id, :class_name => 'Facebook'
end
