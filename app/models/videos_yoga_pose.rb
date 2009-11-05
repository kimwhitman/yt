class VideosYogaPose < ActiveRecord::Base
  belongs_to :video
  belongs_to :yoga_pose
end
