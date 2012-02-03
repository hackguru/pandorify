class Recommendation < ActiveRecord::Base
  belongs_to :facebook
  belongs_to :song
  belongs_to :recommended_by, :class_name => 'Facebook'
end
