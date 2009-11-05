class SkillLevel < ActiveRecord::Base
  has_many :videos
  validates_presence_of :name, :description
end
