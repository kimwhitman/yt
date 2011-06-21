class Instructor < ActiveRecord::Base
  has_attached_file :photo,
    :url => "/system/:attachment/:id/:style/:basename.:extension",
   :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension"
  has_and_belongs_to_many :videos
  validates_presence_of :name
end
