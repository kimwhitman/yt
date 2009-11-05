module Admin::UsersHelper
  def photo_form_column(user, name)  
    html = ''
    html << link_to_paperclip(user.photo, :id => "paperclip_#{user.id}") if user.photo?
    html << '<br/>' if user.photo?
    html << file_field_tag(name)
    html << " " if user.photo?
    html << link_to_remote("delete photo", :url => {:action => "remove_photo", :record => user}, :confirm => "Are you sure you would like to delete this photo?", :html => {:id => "delete_link"}) if user.photo?
    html
  end
  def photo_column(user)
    user.photo? ? (image_tag user.photo.url, :size => "50x50") : "No Photo"
  end

  def membership_type_column(user)
    user.has_paying_subscription? ? "Subscriber" : "Free"
  end
end
