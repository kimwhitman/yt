namespace :videos do
  desc "Query and display YogaToday media in the Delve Platform."
  task :list_remote => [:environment] do
    target = REMOTE_MEDIA_ENDPOINT
    output = ActiveSupport::JSON.decode RestClient.get(target)
    output.each do |media|
      formatted = <<-EOS
      ----
      MEDIA: #{media['media_id']}
      * title: #{media['title']}
      * description: #{media['description']}
      * tags: #{media['tags'].blank? ? 'none' : media['tags'].join(', ')}
      * thumbnail_url: #{media['thumbnail_url']}
      * duration: #{media['duration_in_milliseconds'] / 1000 / 60} minutes.
      * category: #{media['category'].blank? ? 'none' : media['category']}
      ----
      EOS
      puts
      puts formatted
      puts
    end    
  end
  desc "Import default YogaToday video focus category"
  task :import_video_focus => [:environment] do
    [:physical_fitness, :mental_conditioning, :pose_specific, :specialty].each do |name|
      vfs = VideoFocusCategory.find_or_create_by_name name.to_s.titleize
      vfs.save
    end    
  end
  desc "Import default tags from API"
  task :import_tags => [:environment] do
    Video.transaction do
      Video.all.each do |video|
        video.mds_tags = video.tags
        video.save
      end
    end
  end
end