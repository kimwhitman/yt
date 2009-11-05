class Faq < ActiveRecord::Base
  belongs_to :faq_category

  validates_presence_of :question, :answer, :faq_category_id
  validates_associated :faq_category
  validates_length_of :question, :maximum => 400
  validates_length_of :answer, :maximum => 1000
  # For active scaffold to display the correct label in "update"
  def to_label
    "Faq"
  end
end
