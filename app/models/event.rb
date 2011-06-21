class Event < ActiveRecord::Base
  has_attached_file :asset,
    :url => "/system/:attachment/:id/:style/:basename.:extension",
   :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension"

  named_scope :to_show, :conditions => ["events.begin_date < ? AND events.end_date > ? AND active = ?", Time.now.utc, Time.now.utc, true]
end
