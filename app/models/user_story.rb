class UserStory < ActiveRecord::Base
  validates_presence_of :name, :location, :email, :story
  has_attached_file :image
  validates_attachment_size(:image, :less_than => 1.megabyte, :message => "image file size must be less than 1MB.")
  validates_length_of :story, :maximum=> 3500

  named_scope :public, :conditions => { :is_public => true }
  named_scope :by_publish_at, :order => 'publish_at DESC'
  named_scope :published, :conditions => 'user_stories.publish_at <= NOW()'
  named_scope :unpublished, :conditions => 'user_stories.publish_at IS NULL'
  named_scope :publishable, :conditions => 'user_stories.publish_at IS NOT NULL'

  before_save :publish_at_midnight

  def title
    super || story[0..16] + '...'
  end

  protected

  def publish_at_midnight
    self.publish_at = self.publish_at.at_midnight if self.publish_at
  end
end
