class Video < ActiveRecord::Base
  belongs_to :skill_level
  #has_one :video_focus_category, :through => :video_focus
  has_many :featured_videos, :dependent => :destroy
  has_many :comments, :order => 'updated_at DESC'
  has_many :reviews, :order => 'updated_at DESC'
  
  has_and_belongs_to_many :video_focus, :join_table => 'video_video_focus'
  # Do _NOT_ use this assocation for pagination.
  # It doesn't work. Use the named_scope related_videos_for instead, supplying a Video ID.
  has_and_belongs_to_many :related_videos,
    :class_name => 'Video',
    :association_foreign_key => 'related_video_id',
    :join_table => 'related_videos',
    :finder_sql => %q(
      SELECT videos.* FROM `videos` INNER JOIN `related_videos` ON `videos`.id = `related_videos`.related_video_id OR `videos`.id = `related_videos`.video_id WHERE (`related_videos`.video_id = #{id} OR `related_videos`.related_video_id = #{id}) AND videos.id <> #{id}
  )
    
  has_and_belongs_to_many :instructors
  #has_and_belongs_to_many :yoga_poses
  has_and_belongs_to_many :yoga_types

  validates_presence_of :title, :duration, :description, :streaming_media_id
  validates_inclusion_of :is_public, :in => [true, false]
  validates_length_of :title, :maximum => 255, :allow_blank => true
  validates_length_of :description, :maximum => 1000, :allow_blank => true

  before_validation :update_duration, :update_tags, :update_caches
  
  # This association is just used for pagination.
  named_scope :related_videos_for, lambda { |id| 
    {
      :conditions => "(`related_videos`.video_id = #{id} OR `related_videos`.related_video_id = #{id}) AND videos.id <> #{id}",
      :joins => "INNER JOIN `related_videos` ON `videos`.id = `related_videos`.related_video_id OR `videos`.id = `related_videos`.video_id"
    }
  }
  named_scope :public, :conditions => { :is_public => true }
  named_scope :by_title, :order => 'title ASC'
  named_scope :by_most_recent, :order => 'videos.created_at DESC'
  named_scope :by_most_popular,
  	:select => "videos.*, (SELECT COUNT(*) FROM playlist_videos where videos.id = playlist_videos.video_id) as pop_cnt", :order => 'pop_cnt desc'
  named_scope :by_most_discussed,
		:select => "videos.*, (SELECT COUNT(*) FROM comments where videos.id = comments.video_id) as disc_cnt", :order => 'disc_cnt desc'
  named_scope :by_top_rated,
		:select => "videos.*, (SELECT (SUM(reviews.score) / COUNT(reviews.score)) FROM reviews WHERE (videos.id = reviews.video_id AND reviews.score > 0)) as avg_rating", :order => 'avg_rating desc'
  named_scope :search, lambda { |opts|
    opts ||= {}
    conds = {}
    duration_range = nil
    unless opts[:time].blank?
      ranges = {
        :short => "(videos.duration BETWEEN 1 AND #{10.minutes})",
        :med => "(videos.duration BETWEEN #{10.minutes} AND #{30.minutes})",
        :long => "(videos.duration >= #{30.minutes})"
      }.with_indifferent_access
      duration_range = opts[:time].collect { |t| ranges[t] }.join(' OR ')
    end    
    conds.merge! "skill_level_id" => opts[:skill_level],
      "instructors.id" => opts[:instructors],
      "yoga_poses.id"  => opts[:yoga_poses],
      "yoga_types.id"  => opts[:yoga_types],
      "video_focus.id" => opts[:video_focus]
    conds.reject! { |k, v| v.nil? } # Reject all unset (= nil) values
    #TODO: I didn't want to rewrite all of this code just to support a SQL fragment.
    if duration_range
      sanitized = sanitize_sql_for_conditions(conds) || ''
      conds =  sanitized + "#{'AND' unless sanitized.blank?} (#{duration_range})"
    end
    # If a video lacks an associated yoga_pose, yoga_type, or instructor
    # then it's not gonna show up in the search menu 'cuz of the inner joins.
    # It's a little more complicated this way, but it makes the sql query
    # much less intensive.
    joins = [:instructors, :yoga_poses, :yoga_types, :video_focus]
    joins.delete_if { |key_value| opts[key_value].blank? }    
    {
      :select => "videos.*",
      :joins => joins,
      :group => "videos.id",
      :order => 'videos.created_at DESC',
      :conditions => conds
    }
  }
  named_scope :keywords, lambda { |keywords| 
  	keywords ||= ''
  	conds = []
  	joins = "LEFT OUTER JOIN video_video_focus ON video_video_focus.video_id = videos.id LEFT OUTER JOIN video_focus ON video_focus.id = video_video_focus.video_focus_id"
    # There's a bug in Rails 2.1 concerning named_scope and "chaining" inner joins.
    # Hence, video_focus_cache
  	#chain them so we can handle and's and or's in the future.
  	keywords.downcase.gsub(/[,.'"]/, '').gsub(' and ', ' ').gsub(' or ', ' ').split.each do |keyword|
  		conds << "LOWER(videos.title) LIKE '% #{keyword} %'"
  		conds << "LOWER(videos.title) LIKE '#{keyword} %'"
  		conds << "LOWER(videos.title) LIKE '% #{keyword}'"
      conds << "LOWER(videos.title) LIKE '%#{keyword}%'"
  		conds << "LOWER(videos.description) LIKE '% #{keyword} %'"
  		conds << "LOWER(videos.description) LIKE '#{keyword} %'"
  		conds << "LOWER(videos.description) LIKE '% #{keyword}'"
      conds << "LOWER(videos.description) LIKE '%#{keyword}%'"
  		conds << "LOWER(video_focus_cache) LIKE '% #{keyword} %'"
  		conds << "LOWER(video_focus_cache) LIKE '#{keyword} %'"
  		conds << "LOWER(video_focus_cache) LIKE '% #{keyword}'"
      conds << "LOWER(video_focus_cache) LIKE '%#{keyword}%'"
      conds << "LOWER(videos.mds_tags) LIKE '%#{keyword}%'"
      conds << "LOWER(videos.mds_tags) LIKE '% #{keyword} %'"
  		conds << "LOWER(videos.mds_tags) LIKE '#{keyword} %'"
  		conds << "LOWER(videos.mds_tags) LIKE '% #{keyword}'"
  	end
  	{
  		:select => "videos.*",
  		#:joins => joins,
  		:conditions => conds.join(' OR ')
  	}
  }
  # Constants
  # Yes, this is a bad idea.
  # No, I'm going to do it anyway.
  # Too much other stuff to do to get this done on time.
  VIDEO_PRICES = {
    :everyone => 3.99,
    :subscribers => 2.99
  }
  def score
    # We're only doing whole stars for now.
    # half-stars come later.
    if reviews.public.positive_score.count == 0
      return @score ||= 0
    end    
    @score ||= reviews.public.positive_score.sum('score') / reviews.public.positive_score.count
  end
  def focus_name
    !video_focus.blank? ? video_focus.collect { |vf| vf.name }.join(', ') : "Unknown"
  end
  def skill_name
    skill_level ? skill_level.name : "Unknown"
  end
  def instructor_names
    unless instructors.empty?
      instructors.collect { |instructor| instructor.name }
    else
      ["No instructors listed"]
    end
  end
  def style_names
    unless yoga_types.empty?
      yoga_types.collect { |yoga_style| yoga_style.name }
    else
      ["No yoga styles listed"]
    end
  end
  def duration_to_minutes
    self.duration / 60
  end
  def duration_seconds
    "%0.2i" % (self.duration % 60)
  end
  def cart_name
    title
  end
  # See VIDEO_PRICES comment.
  def price(user_or_symbol = :everyone)
    case user_or_symbol
      when User
        user_or_symbol.has_paying_subscription?? VIDEO_PRICES[:subscribers] : VIDEO_PRICES[:everyone]
      when Symbol
        raise "Invalid symbol; got #{user_or_symbol}" unless VIDEO_PRICES.include? user_or_symbol
        VIDEO_PRICES[user_or_symbol]
      when nil
        VIDEO_PRICES[:everyone]
      else
        raise "Invalid parameter passed; expected User or Symbol, got #{user_or_symbol.class.name}"
    end
  end
  def free?
    fv = FeaturedVideo.find_by_video_id(self.id)
    !fv.blank? && fv.free?
  end
  # API-accessing functions
  def thumbnail_url
    Rails.cache.fetch("video_#{id}_remote_thumbnail_url") do
      remote_properties['thumbnail_url']
    end
  end
  def tags
    Rails.cache.fetch("video_#{id}_remote_tags") do
      remote_properties['tags']
    end
  end
  def duration_in_milliseconds
    Rails.cache.fetch("video_#{id}_remote_duration") do
      remote_properties['duration_in_milliseconds']
    end
  end
  # Get an Amazon S3 download URL for this media.
  # :quality: us one of:
  # => :low, :medium, :high, or :hd
  def download_url(quality = :hd)
    return @download_url if @download_url
    # POST 'http://staging-api.delvenetworks.com/rest/organizations/ id>/media//download_url?quality=<{low,medium,high,hd}>'
    url = "#{REMOTE_ORG_ENDPOINT}/media/#{downloadable_media_id}/download_url.json"
    signing_url = "http://#{ENV['api_domain']}/calc_presigned_url"
    # Replace desired URL with signed copy
    url = RestClient.post signing_url, {
      :access_key => DELVE_API_ACCESS_KEY,
      :secret => DELVE_API_SECRET,
      :http_verb => 'post',
      :resource_url => url,
      :quality => quality.to_s
    }    
    # Koichi says this is a string. Just a string. So... let's hope it's just a string.
    @download_url = ActiveSupport::JSON.decode(RestClient.post url, {})    
    rescue RestClient::RequestFailed => rf
      Rails.logger.info "Could not retrieve download_url for #{self.id}; #{rf.response.body}"
      nil
    rescue Exception => e
      Rails.logger.info "Could not retrieve download_url for #{self.id}; #{e.inspect}"
      nil
  end
  protected
  def remote_properties(media_id = nil)
    media_id ||= streaming_media_id    
    @remote_properties ||= ActiveSupport::JSON.decode(RestClient.get "#{REMOTE_ORG_ENDPOINT}/media/#{media_id}/properties.json")
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.info "An error occured trying to retrieve media remote properties: #{e.message} || #{e.response.body}"
  end
  def update_duration    
    if self.streaming_media_id_changed? || self.downloadable_media_id_changed?
      media_id = self.streaming_media_id || self.downloadable_media_id
      return unless media_id
      self.duration = remote_properties(media_id)['duration_in_milliseconds'].to_i / 1000
    end
  end
  def update_tags
    self.mds_tags = self.tags.to_s
  end
  def update_caches
    self.video_focus_cache = self.video_focus.collect(&:name).join(',')
  end
end
