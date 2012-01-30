class Song < ActiveRecord::Base
  has_many :listens
end
