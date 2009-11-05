module Admin::UserStoriesHelper
  def image_column(user_story)
    user_story.image? ?  link_to_paperclip(user_story.image) : "No Image"
  end

  def image_form_column(user_story, name)
    html = ''
    html << link_to_paperclip(user_story.image, :id => "paperclip_#{user_story.id}") if user_story.image?
    html << '<br/>' if user_story.image?
    html << file_field_tag(name)
    html << " " if user_story.image?
    html << link_to_remote("delete image", :url => {:action => "remove_image", :record => user_story}, :confirm => "Are you sure you would like to delete this image?", :html => {:id => "delete_link"}) if user_story.image?
    html
  end

  def story_column(user_story)
    if params[:action] == 'show'
      user_story.story      
    else
      truncate(user_story.story, 120)
    end
  end

  def published_at_column(user_story)
    if user_story.publish_at
      "Published on #{user_story.publish_at.strftime('%m/%d/%Y')}"
    else
      "No publish date set."
    end
  end

  def status_column(user_story)
    if user_story.publish_at
      "<span style='color: #990000;'>Published</span>"
    else
      "Unpublished"
    end
  end

  def is_public_form_column(user_story, name)
    check_box_tag(name, true)
  end
  
  def publish_at_form_column(user_story, name)
    calendar_date_select :record, :publish_at, :popup => 'force', :time => false
  end  

  def personal_message_column(user_story)
    message = user_story.personal_message || 'No Personal Message'
    if params[:action] == 'show'
      h message
    else
      h(truncate(message, 47))
    end
  end  
end
