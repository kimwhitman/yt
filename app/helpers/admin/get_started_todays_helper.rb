module Admin::GetStartedTodaysHelper
  def image_form_column(get_start_today, name)  
    html = ''
    html << link_to_paperclip(get_start_today.image) if get_start_today.image?
    html << '<br/>' if get_start_today.image?
    html << file_field_tag(name)
  end
  def image_column(get_start_today)
    get_start_today.image? ? (image_tag get_start_today.image.url) : "No Photo"
  end
end
