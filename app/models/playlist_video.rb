class PlaylistVideo < ActiveRecord::Base
  belongs_to :user
  belongs_to :video
  validates_presence_of :video_id
  validates_uniqueness_of :video_id, :scope => [:user_id]
  validates_associated :video
end
