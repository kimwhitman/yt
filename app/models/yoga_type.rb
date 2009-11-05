class YogaType < ActiveRecord::Base
  has_and_belongs_to_many :videos

  validates_presence_of :name, :description
  validates_length_of :name, :maximum => 255
  validates_length_of :description, :maximum => 1000, :allow_blank => true
end
