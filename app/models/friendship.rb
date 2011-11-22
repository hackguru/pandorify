class Friendship < ActiveRecord::Base
  belongs_to :user, :class_name => "Facebook"
  belongs_to :friend, :class_name => "Facebook"
end
