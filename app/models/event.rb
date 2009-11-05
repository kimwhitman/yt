class Event < ActiveRecord::Base
  has_attached_file :asset

  named_scope :to_show, :conditions => ["events.begin_date < ? AND events.end_date > ? AND active = ?", Time.now.utc, Time.now.utc, true]
end
