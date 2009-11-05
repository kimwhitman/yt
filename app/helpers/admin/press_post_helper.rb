module Admin::PressPostHelper
  def photo_form_column(press_post, name)  
    html = ''
    html << link_to_paperclip(press_post.photo) if press_post.photo?
    html << '<br/>' if press_post.photo?
    html << file_field_tag(name)
  end
  def photo_column(press_post)
    press_post.photo? ? link_to_paperclip(press_post.photo) : "No Photo"
  end
  def date_posted_form_column(press_post, name)
    calendar_date_select :record, :date_posted, :popup => 'force', :time => false
  end
  def date_posted_column(press_post)
    if press_post.date_posted
      "Posted on #{press_post.date_posted.strftime('%m/%d/%Y')}"
    else
      "No posted date set."
    end
  end
  def body_column(press_post)
    if params[:action] == 'show'
      press_post.body
    else
      truncate(press_post.body, 120)
    end
  end
end
