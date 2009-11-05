class FaqCategory < ActiveRecord::Base
  has_many :faqs
  validates_presence_of :name
  validates_uniqueness_of :name
end
