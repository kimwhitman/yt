class UserPlaylist
  # Accepts a User instance to prime the playlist with
  def initialize(user = nil)
    @videos = []

    if user.is_a? User
      @user_id = user.id
      user.playlist_videos.each { |pv|  @videos << pv.video_id }
    end
  end

  def add(video)
    return unless video
    if @user_id
      PlaylistVideo.find_or_create_by_user_id_and_video_id(@user_id, video.id)
    end
    unless @videos.include?(video.id)
      @videos << video.id
    end
  end

  def remove(video)
    return unless video
    if @user_id
      plv = PlaylistVideo.find_by_user_id_and_video_id(@user_id, video.id)
      plv.destroy unless plv.nil?
    end

    @videos.delete video.id
  end

  def has_video?(video)
    return false unless video
    @videos.include? video.id
  end

  def size
    @videos.size
  end

  # Class methods
  def self.migrate_to_user(user_id, temp_playlist)
    if @user_id
      raise StandardError.new "This playlist already belongs to a user."
    end
    user = User.find(user_id)
    playlist = UserPlaylist.new user
    temp_playlist.videos.each do |video|
      playlist.add(video)
    end
    playlist
  end

  def videos
    ids = @videos
    if @user_id
      ids = PlaylistVideo.find_all_by_user_id(@user_id).collect { |pv| pv.video_id }
    end
    Video.find(:all, :conditions => { :id => ids })
  end
end
