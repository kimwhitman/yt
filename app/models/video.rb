class Video < ActiveRecord::Base

  DEFAULT_BRIGHTCOVE_PLAYER_ID = 641807589001

  class BrightcoveApiError < StandardError; end
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

  validates_presence_of :title, :duration, :description, :instructors, :yoga_types
  validates_inclusion_of :is_public, :in => [true, false]
  validates_length_of :title, :maximum => 255, :allow_blank => true
  validates_length_of :description, :maximum => 1000, :allow_blank => true

  before_validation :update_caches

  # This association is just used for pagination.
  named_scope :related_videos_for, lambda { |id|
    {
      :conditions => "(`related_videos`.video_id = #{id} OR `related_videos`.related_video_id = #{id}) AND videos.id <> #{id}",
      :joins => "INNER JOIN `related_videos` ON `videos`.id = `related_videos`.related_video_id OR `videos`.id = `related_videos`.video_id"
    }
  }
  named_scope :published, lambda { { :conditions => [ 'is_public = ? AND published_at <= ?', true, Time.zone.now ] } }
  named_scope :upcoming, lambda { { :conditions => [ 'is_public = ? AND published_at > ?', true, Time.zone.now ], :order => 'published_at ASC' } }
  named_scope :this_week, lambda { { :conditions => {:published_at => (Time.zone.today.beginning_of_week..Time.zone.today.next_week)}, :order => 'published_at ASC' }}

  named_scope :after_this_week, lambda { { :conditions => ['published_at >= ?', Time.zone.today.next_week], :order => 'published_at ASC' } }

  named_scope :recently_released, lambda { { :conditions =>
    { :published_at => (2.weeks.ago.beginning_of_week..1.weeks.ago.end_of_week) }, :order => 'published_at ASC' } }

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

  def self.brightcove_api
    { :read => Brightcove::API.new(BRIGHTCOVE_API_KEYS[:read]),
      :write => Brightcove::API.new(BRIGHTCOVE_API_KEYS[:write])}
  end

  def self.convert_brightcove_reference_id(reference_id)
    if reference_id
      converted_name = reference_id.gsub('_PV', '').gsub('-HD', '')

      case converted_name.size
        when 2 : converted_name.insert(1, '00')
        when 3 : converted_name.insert(1, '0')
      end

      converted_name
    end
  end

  def self.fetch_videos_from_brightcove(method, options = {})
    video_options = { :page_size => 100,
      :custom_fields => 'skilllevel,instructor,public,yogatypes,yogatypes2,relatedvideos,videofocus,previewvideo,assignedplayerid' }

    # Convert UNIX epoch time to minutes
    options[:from_date] = ((Time.now - options[:updated_since]).to_i / 60) if options[:updated_since]
    options.delete(:updated_since)

    video_options.merge!(options)

    brightcove_videos = []
    page_number = 0
    loop do
      videos = Hashie::Mash.new(Video.brightcove_api[:read].get(method, video_options.merge!(:page_number => page_number)))

      raise Video::BrightcoveApiError, "Code: #{videos.code}, Error: #{videos.error}" if !videos.errors.blank?

      break if videos.items.blank? || (options[:page_number] && page_number == options[:page_number])

      videos.first.each do |video|
        brightcove_videos << video unless video.is_a? String
      end

      page_number += 1
    end

    return brightcove_videos.flatten
  end

  def self.import_videos_from_brightcove(updated_since = 86400)
    invalid_videos = []
    brightcove_videos = self.fetch_videos_from_brightcove('find_modified_videos', :updated_since => updated_since)

    brightcove_videos.each do |brightcove_video|
      if Video.full_version?(brightcove_video)
        video = Video.find_or_initialize_by_friendly_name(brightcove_video.referenceId)

        video_attributes = { :title => brightcove_video.name,
          :duration => brightcove_video.videoFullLength.videoDuration.to_i / 1000,
          :published_at => brightcove_video.publishedDate.to_i,
          :is_public => (brightcove_video.customFields.public == 'True' ? true : false),
          :created_at => video.new_record? ? Time.now : brightcove_video.creationDate.to_i,
          :updated_at => video.new_record? ? Time.now : brightcove_video.lastModifiedDate.to_i,
          :description => brightcove_video.longDescription,
          :brightcove_full_video_id => brightcove_video.id,
          :brightcove_preview_video_id => brightcove_video.customFields.previewVideo,
          :mds_tags => brightcove_video.tags }

        video.attributes = video_attributes

        # Find Associations
        instructors = [Instructor.find_by_name(brightcove_video.customFields.instructor)]
        yoga_types = [YogaType.find_by_name(brightcove_video.customFields.yogatypes),
          YogaType.find_by_name(brightcove_video.customFields.yogatypes2)].compact
        skill_level = SkillLevel.find_by_name(brightcove_video.customFields.skilllevel)
        video_focuses = []
        brightcove_video.customFields.videofocus.split(", ").each do |video_focus|
          video_focuses << VideoFocus.find_by_name(video_focus)
        end
        video_focuses.compact!

        # Setup Associations
        video.instructors << instructors
        video.yoga_types << yoga_types
        video.skill_level = skill_level
        video.video_focus << video_focuses

        if video.valid?
          video.save
        else
          invalid_videos << video
        end
      end
    end
    rescue Video::BrightcoveApiError => exception
      logger.warn("There was an exception returning data from Brightcove. The exception was #{exception}")
  end

  def self.full_version?(reference_id)
    reference_id.include?('-HD') ? true : false
  end

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
        user_or_symbol.has_paying_subscription? ? VIDEO_PRICES[:subscribers] : VIDEO_PRICES[:everyone]
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

  def could_be_free?
    fv = FeaturedVideo.find_by_video_id(self.id)
    !fv.blank? && fv.could_be_free?
  end

  def starts_free_at
    fv = featured_videos.find(:first, :order => 'starts_free_at DESC')
    fv.starts_free_at
  end

  def ends_free_at
    fv = featured_videos.find(:first, :order => 'starts_free_at DESC')
    fv.ends_free_at
  end

  # API-accessing functions
  def thumbnail_url
    Rails.cache.fetch("video_#{id}_remote_thumbnail_url") do
      self.fetch_from_brightcove.thumbnailURL if self.fetch_from_brightcove
    end
  end

  def tags
    self.mds_tags
  end

  def duration_in_milliseconds
    self.duration
  end

  def download_url
    self.fetch_from_brightcove.renditions.select { |video| video.url if video.frameWidth == 640 && video.frameHeight == 360 }.first.url
  end

  def fetch_from_brightcove
    return nil if self.brightcove_full_video_id.blank?

    response = Hashie::Mash.new(Video.brightcove_api[:read].get('find_video_by_id', { :video_id => self.brightcove_full_video_id,
      :custom_fields => 'skilllevel,instructor,public,yogatypes,yogatypes2,relatedvideos,videofocus,previewvideo',
      :media_delivery => 'http' }))

    if !response.error.blank?
      raise Video::BrightcoveApiError, "Code: #{response.code}, Error: #{response.error}"
    else
      return response
    end
  end

  def update_brightcove_data!
    response = Hashie::Mash.new(Video.brightcove_api[:write].post('update_video', :video => { :id => self.brightcove_full_video_id, :name => self.title,
      :longDescription => self.description,
      :customFields => { :instructor => self.instructors.map(&:name).join(', '),
        :skilllevel => self.skill_level.name,
        :relatedvideos => self.related_videos.map(&:friendly_name).join(', '),
        :videofocus => self.video_focus.map(&:name).join(', '),
        :public => self.is_public.to_s.titleize,
        :previewvideo => self.brightcove_preview_video_id.to_s,
        :yogatypes => (!self.yoga_types.blank? ? self.yoga_types.first.name.strip),
        :yogatypes2 => (self.yoga_types.size > 1 ? self.yoga_types.last.name.strip) },
      :tags => (self.tags.blank? ? [] : [self.tags]) }))

      if !response.error.blank?
        raise Video::BrightcoveApiError, "Code: #{response.code}, Error: #{response.error}"
      else
        return response
      end
  end

  protected

    def update_caches
      self.video_focus_cache = self.video_focus.collect(&:name).join(',')
    end
end
