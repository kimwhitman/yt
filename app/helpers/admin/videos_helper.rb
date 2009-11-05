module Admin::VideosHelper
  def preview_media_id_form_column(video, input_name)
    select :record, :preview_media_id,
      @media.collect { |m| [m['title'], m['media_id']] },
      { :selected => video.preview_media_id, :include_blank => "- None -" },
      { :name => input_name }
  end

  def streaming_media_id_form_column(video, input_name)
    select :record, :preview_media_id,
      @media.collect { |m| [m['title'], m['media_id']] },
      { :selected => video.streaming_media_id, :include_blank => "- None -" },
      { :name => input_name }
  end

  def downloadable_media_id_form_column(video, input_name)
    select :record, :preview_media_id,
      @media.collect { |m| [m['title'], m['media_id']] },
      { :selected => video.downloadable_media_id, :include_blank => "- None -" },
      { :name => input_name }
  end

  def related_videos_form_column(video, input_name)
    input_name << '[]'
    videos = Video.find(:all, :order => 'friendly_name, title').reject { |v| v.id == video.id }
    options = videos.inject({}) { |h, v| h.merge({ "#{v.friendly_name} - #{v.title}" => v.id }) }
    selected = begin
      selected = Video.related_videos_for(video.id).collect { |v| v.id }
    rescue
    end

    select_tag input_name, options_for_select(options, selected), :multiple => true
  end

  def is_public_column(video)
    video.is_public? ? "Yes" : "No"
  end

  def skill_level_id_form_column(video, input_name)
    select :record, :skill_level_id,
      "SkillLevel".constantize.all.collect { |sl| [sl.name, sl.id] },
      { :selected => video.skill_level_id },
      { :name => input_name}
  end
end
