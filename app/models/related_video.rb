class RelatedVideo < ActiveRecord::Base
  belongs_to :video
  belongs_to :related_video, :class_name => 'Video'

  validates_presence_of :video_id, :related_video_id
  validates_uniqueness_of :video_id, :scope => :related_video_id
  validates_uniqueness_of :related_video_id, :scope => :video_id
end
