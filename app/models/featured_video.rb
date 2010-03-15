class FeaturedVideo < ActiveRecord::Base
  has_attached_file :image,
    :styles => {
      :thumb => '106x59',
      :carousel => '940x526'
    }

  belongs_to :video

  validates_presence_of :video_id, :rank
  validates_numericality_of :rank
  validates_uniqueness_of :video_id
  validate :free_range_validation

  named_scope :by_rank, :order => "rank ASC"
  named_scope :previously_featured, :conditions => ['starts_free_at <= ?', Date.today]
  named_scope :free_videos,
    :conditions => "NOW() between featured_videos.starts_free_at AND featured_videos.ends_free_at"

  before_validation :set_rank

  # Accepts an array of FeaturedVideo ID's.
  # Updates their rank to correspond with their position in the array.
  # [5, 3, 1] will give ID: 5 a rank of 0, ID: 3 a rank of 1, and ID: 1 a rank of 3
  def self.update_ranks(ids = [])
    ids.each_with_index do |id, index|
      FeaturedVideo.update id, :rank => index
    end
  end

  def could_be_free?
    !starts_free_at.blank? && !ends_free_at.blank?
  end

  def free?
    return false unless could_be_free?
    (starts_free_at..ends_free_at).include? Time.now
  end

  def thumbnail
    image? ? image.url(:carousel) : video.thumbnail_url
  end

  # For active scaffold to display the correct label in "update"
  def to_label
    "Featured Video"
  end

  def published_at
    starts_free_at
  end

  protected

  def free_range_validation
    if starts_free_at.blank? && !ends_free_at.blank?
      errors.add :starts_free_at, "must be provided when using an end date."
    elsif !starts_free_at.blank? && ends_free_at.blank?
      errors.add :ends_free_at, "must be provided when using a start date."
    end
    return true unless starts_free_at && ends_free_at
    unless ends_free_at > starts_free_at
      errors.add_to_base 'The start date range must be before the end date range.'
    end
  end

  def set_rank
    if self.rank.blank?
      self.rank = FeaturedVideo.count + 1
    end
  end
end
