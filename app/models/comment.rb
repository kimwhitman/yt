class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  validates_presence_of :content, :video_id #, :user_id,
  validates_inclusion_of :is_public, :in => [true, false]
  validates_associated :video #, :user
  validates_length_of :content, :maximum => 1000
  validates_length_of :title, :maximum => 255

  named_scope :public, :conditions => { :is_public => true }
  named_scope :topics, :conditions => 'parent_comment_id IS NULL'
  has_many :responses, :class_name => "Comment", :foreign_key => :parent_comment_id
  belongs_to :parent_comment, :class_name => "Comment"
end
