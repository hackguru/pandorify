class RequestedSongs < ActiveRecord::Base
  belongs_to :song
  belongs_to :party
  belongs_to :facebook
end
