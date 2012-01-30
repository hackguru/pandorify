class Song < ActiveRecord::Base
  has_many :listens
  belongs_to :application
end
