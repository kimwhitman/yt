module Admin::InstructorsHelper
  def photo_form_column(instructor, name)
    html = ''
    html << link_to_paperclip(instructor.photo) if instructor.photo?
    html << '<br/>' if instructor.photo?
    html << file_field_tag(name)
  end

  def photo_column(instructor)
    instructor.photo? ? (image_tag instructor.photo.url, :size => "64x64") : "No Photo"
  end
end
