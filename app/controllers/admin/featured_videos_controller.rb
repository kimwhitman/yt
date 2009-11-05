class Admin::FeaturedVideosController < Admin::BaseController
   active_scaffold :featured_videos do |config|
    list_or_show_columns = [:title, :high_definition_thumbnail, :free_date_range]
    config.list.columns = list_or_show_columns
    config.show.columns = list_or_show_columns
    config.list.sorting = { :rank => :asc }
    config.columns[:video].form_ui = :select
    config.columns[:video].search_sql = 'videos.title'
    config.search.columns = :video
    config.update.multipart = true
    create_or_update_columns = [:video, :image, :starts_free_at, :ends_free_at]
    config.create.columns = create_or_update_columns
    config.update.columns = create_or_update_columns
  end

  def set_ranks
    FeaturedVideo.update_ranks(params[:featured_video_id])
    expire_fragment "pages/home/carousel"
    expire_action "pages/home"
    redirect_to :action => 'list'
  end

  def after_create_save(record)
    expire_fragment "pages/home/carousel"
    expire_action "pages/home"
  end

  def after_update_save(record)
    expire_fragment "pages/home/carousel"
    expire_action "pages/home"
  end
end
