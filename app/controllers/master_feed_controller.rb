class MasterFeedController < ApplicationController
  def index
    @free_video = FeaturedVideo.free_videos.first
    @featured_video = FeaturedVideo.find(:first)

    # TODO this is duplicated in the Videos controller, need to consolidate into a model method when time permits
    @this_weeks_videos = Video.find_by_sql(["SELECT videos.id, videos.title, videos.description, videos.streaming_media_id, skill_level_id, published_at,
      featured_videos.starts_free_at FROM videos LEFT OUTER JOIN `featured_videos` ON featured_videos.video_id = videos.id
      WHERE  (`videos`.`published_at` BETWEEN ? AND ?) OR (featured_videos.starts_free_at BETWEEN ? AND ?)
      ORDER BY (CASE WHEN starts_free_at IS NULL THEN published_at ELSE starts_free_at END) ASC,
      (CASE WHEN starts_free_at IS NULL THEN 2 ELSE 1 END) ASC;",
      Time.zone.now.beginning_of_week, Time.zone.now.end_of_week,
      Time.zone.now.beginning_of_week, Time.zone.now.end_of_week])
    render :action => 'index'
  end
end
