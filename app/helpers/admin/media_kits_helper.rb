module Admin::MediaKitsHelper
  def image_form_column(media_kit, name)  
    html = ''
    html << link_to_paperclip(media_kit.image) if media_kit.image?
    html << '<br/>' if media_kit.image?
    html << file_field_tag(name)
  end
  def image_column(media_kit)
    media_kit.image? ? link_to_paperclip(media_kit.image) : "No Image"
  end
  def media_kit_type_form_column(media_kit, name)
    select_tag "record[media_kit_type]", options_for_select([["For Print"], ["For Web"]], media_kit.media_kit_type)
  end

end
