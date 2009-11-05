class VideosYogaType < ActiveRecord::Base
  belongs_to :video
  belongs_to :yoga_type
end
