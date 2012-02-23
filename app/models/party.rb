class Party < ActiveRecord::Base
  has_and_belongs_to_many :facebooks, :join_table => "facebooks_parties"
  has_many :songs, :through => :requestedsongs, :source => :song
  has_many :requestedsongs, :dependent => :destroy
  belongs_to :host, :foreign_key => :host_id, :class_name => 'Facebook'
end
