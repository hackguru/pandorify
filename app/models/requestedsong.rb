class Requestedsong < ActiveRecord::Base
  belongs_to :facebook
  belongs_to :song
  belongs_to :party
end
