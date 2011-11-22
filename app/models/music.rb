class Music < ActiveRecord::Base
  has_and_belongs_to_many :facebooks
  validates_uniqueness_of :identifier
end
