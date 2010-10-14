xml.instruct! :xml, :version => "1.0"
unless @featured_video.nil?
  xml.tag! 'featured_video_title', @featured_video.video.title
  xml.tag! 'featured_video_description', @featured_video.video.description
  xml.tag! 'featured_video_instuctors', @featured_video.video.instructor_names
  xml.tag! 'featured_video_skill_level', @featured_video.video.skill_name
  xml.tag! 'featured_video_published_at', @featured_video.video.published_at
  xml.tag! 'featured_video_link_url', video_url(@featured_video.video)
  xml.tag! 'featured_video_thumbnail_url', @featured_video.video.thumbnail_url
end

unless @free_video.nil?
  xml.tag! 'free_video_title', @free_video.video.title
  xml.tag! 'free_video_description', @free_video.video.description
  xml.tag! 'free_video_instuctors', @free_video.video.instructor_names
  xml.tag! 'free_video_skill_level', @free_video.video.skill_name
  xml.tag! 'free_video_published_at', @free_video.video.published_at
  xml.tag! 'free_video_link_url', video_url(@free_video.video)
  xml.tag! 'free_video_thumbnail_url', @free_video.video.thumbnail_url
end

@this_weeks_videos.each_with_index do |video, idx|
  xml.tag! "lineup_video_#{idx + 1}_title", video.title
  xml.tag! "lineup_video_#{idx + 1}_description", video.description
  xml.tag! "lineup_video_#{idx + 1}_instuctors", video.instructor_names
  xml.tag! "lineup_video_#{idx + 1}_skill_level", video.skill_name
  xml.tag! "lineup_video_#{idx + 1}_published_at", video.published_at
  xml.tag! "lineup_video_#{idx + 1}_link_url", video_url(video)
  xml.tag! "lineup_video_#{idx + 1}_thumbnail_url", video.thumbnail_url
end