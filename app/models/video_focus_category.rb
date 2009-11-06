class VideoFocusCategory < ActiveRecord::Base
  has_many :video_focuses, :class_name => 'VideoFocus'
  validates_presence_of :name
end
