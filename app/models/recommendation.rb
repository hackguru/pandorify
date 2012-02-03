class Recommendation < ActiveRecord::Base
  belongs_to :facebook
  belongs_to :song
end
