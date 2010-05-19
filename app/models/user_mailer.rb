class UserMailer < ActionMailer::Base

  def email_confirmation(user, membership)
    subject "Please confirm your email!"
    recipients "#{user.name} <#{user.email}>"
    from "YogaToday <info@yogatoday.com>"
    body :user => user, :membership => membership

    set_content_type(user)
  end

  def password_reset(reset)
    subject 'Password Reset Request'
    recipients reset.user.email
    from "no-reply@yogatoday.com"
    body :reset => reset

    set_content_type(reset.user)
  end

  def password_reset_confirmation(user)
    subject 'Password Reset Confirmation'
    recipients user.email
    from "no-reply@yogatoday.com"
    body :user => user

    set_content_type(user)
  end

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
  end

  def user_story_submitted(user_story)
    subject "Your user story has been submitted"
    recipients "#{user_story.name} <#{user_story.email}>"
    from "no-reply@yogatoday.com"
    body :user_story => user_story
  end

  def welcome(user)
    subject "Welcome to Yoga Today!"
    recipients "#{user.name} <#{user.email}>"
    from "YogaToday <info@yogatoday.com>"
    body :user => user
    set_content_type(user)
  end

  def ambassador_invite(ambassador, from, recipient, email_subject, message)
    subject email_subject
    recipients "#{ recipient } <#{ recipient }>"
    from "YogaToday <#{ from }>"
    url = ShareUrl.create(:user_id => ambassador.id, :destination => "http://#{ HOST }/sign-up?ambassador_user_id=#{ ambassador.id }").url
    body :message => message, :ambassador => ambassador, :url => url
    @content_type = 'text/html'
  end

  def ambassador_reward_notification(user, rewarding_user)
    subject "Ambassador Reward"
    recipients "#{user.name} <#{user.email}>"
    from "YogaToday <info@yogatoday.com>"
    body :user => user, :rewarding_user => rewarding_user
  end


  private

    def set_content_type(user)
      @content_type = (user.newsletter_format == 'html') ? 'text/html' : 'text/plain'
    end
end
