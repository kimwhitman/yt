class AdminNotifier < ActionMailer::Base
  def contact_email(contact_email)
    reply_to "#{contact_email.full_name} <#{contact_email.email}>"
    from "no-reply@yogatoday.com"
    recipients "info@yogatoday.com"
    subject "New Contact Message"
    body :contact_email => contact_email
  end
  def video_suggestion(suggestion, user = nil)
    video = Video.find(suggestion.video_id)
    if user
      reply_to "#{user.name} <#{user.email}>"
    end
    from "no-reply@yogatoday.com"
    recipients "info@yogatoday.com"
    subject "New Video Suggestion Message"
    body :suggestion => suggestion, :video => video, :user => user
  end
  def user_story_thank_you(user_story)
    from "no-reply@yogatoday.com"
    recipients user_story.email
    subject "Thank you for your story"
    body :user_story => user_story
  end
  def offensive_comment
    from "no-reply@yogatoday.com"
    recipients "info@yogatoday.com"
    subject "Possible Offensive Comment"
  end

end