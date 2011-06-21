class PressPost < ActiveRecord::Base
  has_attached_file :photo,
    :url => "/system/:attachment/:id/:style/:basename.:extension",
   :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension"

  validates_presence_of :title, :body
end
