class Review < ActiveRecord::Base
  belongs_to :video
  belongs_to :user

  #validates_presence_of :content, :video_id if self.score <= 0
  #validates_presence_of :score, :video_id if self.content.blank
  validates_inclusion_of :is_public, :in => [true, false]
  validates_inclusion_of :score, :in => (0..5)
  validates_associated :video#, :user
  validates_length_of :content, :maximum => 1000
  validates_length_of :title, :maximum => 255
  
  named_scope :public, :conditions => { :is_public => true }
  named_scope :positive_score, :conditions => ['score > 0']
end
