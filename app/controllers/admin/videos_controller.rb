class Admin::VideosController < Admin::BaseController
  active_scaffold :videos do |config|
    config.columns[:friendly_name].label = 'Custom ID'
    config.list.columns = [:title, :friendly_name, :description, :skill_level, :is_public, :published_at, :instructors, :tags]
    config.list.sorting = { :title => :asc }
    config.columns[:is_public].label = "Public?"
    config.columns[:published_at].label = 'Published At'
    config.columns[:streaming_media_id].label = "Streaming Video"
    config.columns[:preview_media_id].label = "Preview Video"
    config.columns[:downloadable_media_id].label = "Downloadable Video"
    config.columns[:instructors].form_ui = :select
    config.columns[:yoga_types].form_ui = :select
    config.columns[:video_focus].form_ui = :select
    #config.columns[:related_videos].form_ui = :select
    create_or_update_columns = [:title, :friendly_name, :description, :skill_level_id, :is_public,
      :published_at, :instructors, :yoga_types, :related_videos,
      :video_focus, :preview_media_id, :streaming_media_id, :downloadable_media_id, :tags]
    config.create.columns = create_or_update_columns
    config.update.columns = create_or_update_columns
    config.search.columns = [:title, :description, :instructors]
    config.columns[:instructors].search_sql = 'instructors.name'
  end
  before_filter :setup_media, :only => [:new, :edit, :create, :update]

  def featured
    @featured_videos = FeaturedVideo.by_rank(:include => [:video])
    @videos = Video.by_title(:conditions => "videos.id NOT IN (SELECT video_id from featured_videos)")
  end

  protected

  def setup_media
    # This version of RestClient doesn't support timeout.
    # unfortunately we've patched it to support digest authentication.
    # Restclient sucks. Use httpclient2 next time.
    begin
      @media_unsorted = ActiveSupport::JSON.decode RestClient.get(REMOTE_MEDIA_ENDPOINT)
    rescue RestClient::RequestTimeout
      @media_unsorted = ActiveSupport::JSON.decode RestClient.get(REMOTE_MEDIA_ENDPOINT)
    end
    @media = @media_unsorted.sort_by{|item| item["media_id"]}.sort_by{|item| item["title"]}
  end
  #def index
  #  @videos = Video.all
  #end
  #def edit
  #  @video = Video.find(params[:id])
  #  @media = ActiveSupport::JSON.decode RestClient.get(REMOTE_MEDIA_ENDPOINT)
  #end
  #def new
  #  @video = Video.new
  #  @media = ActiveSupport::JSON.decode RestClient.get(REMOTE_MEDIA_ENDPOINT)
  #end

  # CRUD
 #def create
 #   @media = ActiveSupport::JSON.decode RestClient.get(REMOTE_MEDIA_ENDPOINT)
 #   @video = Video.new params[:video]
 #   @video.duration = @video.duration_in_milliseconds / 1000
 #   @video.is_public = true
 #   params[:instructor_ids].each { |id| @video.instructors << Instructor.find(id) } unless params[:instructor_ids].blank?
 #   params[:yoga_type_ids].each { |id| @video.yoga_types << YogaType.find(id) } unless params[:instructor_ids].blank?
 #   params[:yoga_pose_ids].each { |id| @video.yoga_poses << YogaPose.find(id) } unless params[:instructor_ids].blank?
 #   if @video.save
 #     flash[:notice] = "Video created."
 #     redirect_to :action => 'index'
 #   else
 #     render :action => 'new'
 #   end
  #end
  #def update
  #  @media = ActiveSupport::JSON.decode RestClient.get(REMOTE_MEDIA_ENDPOINT)
  #  @video = Video.find params[:id]
  #  @video.attributes = params[:video]
  #  @video.duration = @video.duration_in_milliseconds / 1000
  #  @video.yoga_types.clear
  #  @video.yoga_poses.clear
  #  @video.instructors.clear
  #  params[:instructor_ids].each { |id| @video.instructors << Instructor.find(id) } unless params[:instructor_ids].blank?
  #  params[:yoga_type_ids].each { |id| @video.yoga_types << YogaType.find(id) } unless params[:instructor_ids].blank?
  #  params[:yoga_pose_ids].each { |id| @video.yoga_poses << YogaPose.find(id) } unless params[:instructor_ids].blank?
  #  if @video.save
  #    flash[:notice] = "Video updated"
  #    redirect_to :action => 'index'
  #  else
  #    render :action => 'edit'
  #  end
  #
  #end
end
