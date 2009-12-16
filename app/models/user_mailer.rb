class UserMailer < ActionMailer::Base

  @bcc = 'user@domain.local' if Rails.env == 'cucumber'

  def purchase_confirmation(purchase, sent_at = Time.now)
    subject    "Thank you for your recent purchase ##{purchase.invoice_no}"
    recipients purchase.email
    from       'sales@yogatoday.com'
    sent_on    sent_at
    body       :purchase =>  purchase
  end

  def user_story_published(user_story)
    subject "Your user story has been published!"
    recipients "#{user_story.name} <#{user_story.email}>"
    from "no-reply@yogatoday.com"
    body :user_story => user_story
    @content_type = 'text/html'
  end

  def user_story_submitted(user_story)
    subject "Your user story has been submitted"
    recipients "#{user_story.name} <#{user_story.email}>"
    from "no-reply@yogatoday.com"
    body :user_story => user_story
    @content_type = 'text/html'
  end

  private
    def set_content_type(user)
      @content_type = (user.newsletter_format == 'html') ? 'text/html' : 'text/plain'
    end
end
