class GetStartedToday < ActiveRecord::Base
  has_attached_file :image

  def to_label
    "Get Started Today"
  end
end
