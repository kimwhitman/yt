class UserPlaylist  
  # Accepts a User instance or an array of video ids to prime the playlist with.
  def initialize(user_record_or_array = nil)
    @videos = []
    case user_record_or_array
    when User
      @user_id = user_record_or_array.id
      user_record_or_array.playlist_videos.each { |pv|  @videos << pv.video_id }        
    when Array
      @videos = pv.dup
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
      PlaylistVideo.find_by_user_id_and_video_id(@user_id, video.id).destroy
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
