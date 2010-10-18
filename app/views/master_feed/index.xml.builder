xml.instruct! :xml, :version => "1.0"
xml.tag! 'master_feed' do
  unless @featured_video.nil?
    xml.tag! 'featured_video_title', @featured_video.video.title.strip
    xml.tag! 'featured_video_description', @featured_video.video.description.strip
    xml.tag! 'featured_video_instuctors', @featured_video.video.instructor_names
    xml.tag! 'featured_video_skill_level', @featured_video.video.skill_name
    xml.tag! 'featured_video_published_at', pretty_date_for_xml(@featured_video.starts_free_at)
    xml.tag! 'featured_video_link_url', video_url(@featured_video.video)
    xml.tag! 'featured_video_thumbnail_url', @featured_video.video.thumbnail_url
  end

  unless @free_video.nil?
    xml.tag! 'free_video_title', @free_video.video.title.strip
    xml.tag! 'free_video_description', @free_video.video.description.strip
    xml.tag! 'free_video_instuctors', @free_video.video.instructor_names
    xml.tag! 'free_video_skill_level', @free_video.video.skill_name
    xml.tag! 'free_video_published_at', pretty_date_for_xml(@free_video.starts_free_at)
    xml.tag! 'free_video_link_url', video_url(@free_video.video)
    xml.tag! 'free_video_thumbnail_url', @free_video.video.thumbnail_url
  end

  @this_weeks_videos.each_with_index do |video, idx|
    xml.tag! "lineup_video_#{idx + 1}_title", video.title.strip
    xml.tag! "lineup_video_#{idx + 1}_description", video.description.strip
    xml.tag! "lineup_video_#{idx + 1}_instuctors", video.instructor_names
    xml.tag! "lineup_video_#{idx + 1}_skill_level", video.skill_name
    if @video.could_be_free?
      xml.tag! "lineup_video_#{idx + 1}_published_at", pretty_date_for_xml(video.starts_free_at)
    else
      xml.tag! "lineup_video_#{idx + 1}_published_at", pretty_date_for_xml(video.published_at)
    end
    xml.tag! "lineup_video_#{idx + 1}_link_url", video_url(video)
    xml.tag! "lineup_video_#{idx + 1}_thumbnail_url", video.thumbnail_url
  end

  if @user_story
    xml.tag! "user_story_name", @user_story.name.strip
    xml.tag! "user_story_title", @user_story.title.strip
    xml.tag! "user_story_location", @user_story.location.strip
    xml.tag! "user_story_body", @user_story.story.strip
    xml.tag! "user_story_photo", 'http://yogatoday.com/system' + @user_story.image.url
    xml.tag! "user_story_published_at", pretty_date_for_xml(@user_story.publish_at)
  end
end
