module Admin::FeaturedVideosHelper
  def title_column(featured_video)
    featured_video.video.title
  end

  def high_definition_thumbnail_column(featured_video)
    featured_video.image? ? "Available" : "Unavailable"
  end

  def free_date_range_column(featured_video)
    if featured_video.could_be_free?
      "#{featured_video.starts_free_at.strftime('%m/%d/%y')} -- #{featured_video.ends_free_at.strftime('%m/%d/%y')}"
    else
      "Premium video only."
    end
  end

  def starts_free_at_form_column(featured_video, name)
    calendar_date_select :record, :starts_free_at, :popup => 'force', :time => false
  end

  def ends_free_at_form_column(featured_video, name)
    calendar_date_select :record, :ends_free_at, :popup => 'force', :time => false
  end

  def image_form_column(featured_video, name)
    html = ''
    html << link_to_paperclip(featured_video.image) if featured_video.image?
    html << '<br/>' if featured_video.image?
    html << file_field_tag(name)
  end
end
