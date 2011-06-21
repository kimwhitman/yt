class MediaKit < ActiveRecord::Base
  has_attached_file :image,
    :url => "/system/:attachment/:id/:style/:basename.:extension",
   :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension"
end
