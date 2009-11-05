class VideoFocus < ActiveRecord::Base
  belongs_to :video_focus_category
  has_and_belongs_to_many :videos,
    :join_table => 'video_video_focus'
  validates_presence_of :video_focus_category_id, :name
  validates_associated :video_focus_category
end
