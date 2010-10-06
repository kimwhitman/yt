namespace :videos do
  desc "Initial Import"
  task :initial_import => :environment do
    require 'json/pure'

    brightcove_videos = Video.fetch_videos_from_brightcove('find_all_videos')

    found_videos = []

    brightcove_videos.each do |brightcove_video|
      puts "Processing video #{brightcove_video.name}"
      video = Video.find_by_friendly_name(Video.convert_brightcove_reference_id(brightcove_video.referenceId))

      if video
        video.update_attributes(:brightcove_id => brightcove_video.id)
        puts "Updating Data on Brightcove..."
        video.reload
        response = video.update_brightcove_data!
      end

      if video
        found_videos << video
      else
        puts "Could not find matching video for #{brightcove_video.name} with reference ID #{brightcove_video.referenceId} : #{Video.convert_brightcove_reference_id(brightcove_video.referenceId)}"
      end
    end

    puts "Videos Found #{found_videos.size}"
  end

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

  # FIXME: account for file types other than jpg
  namespace :featured do
    desc 'Update Featured Video thumbnails with those from Delve'
    task :update_thumbnails => [:environment] do
      require 'open-uri'

      featured_videos = FeaturedVideo.by_rank(:include => [:video])

      featured_videos.each do |featured_video|
        video = featured_video.video
        if video && video.thumbnail_url != ''
          begin
            io = open(URI.parse(video.thumbnail_url))

            featured_video.image = io
            featured_video.image.instance_write(:file_name, "image.jpg")

            if featured_video.save!
              puts "Updated [#{featured_video.id}] thumbnail from: #{video.thumbnail_url}"
            end
          rescue Exception => e
            puts "Couldn't connect to URL: #{e}"
          end
        end
      end

    end
  end
end