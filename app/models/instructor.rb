class Instructor < ActiveRecord::Base
  has_attached_file :photo
  has_and_belongs_to_many :videos
  validates_presence_of :name
end
