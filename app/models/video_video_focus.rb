class VideoVideoFocus < ActiveRecord::Base
  belongs_to :video
  belongs_to :video_focus
  
  validates_presence_of :video_id, :video_focus_id
end
