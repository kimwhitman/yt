class SubscriptionNotifier < ActionMailer::Base
  include ActionView::Helpers::NumberHelper

  def setup_email(to, subject, from = AppConfig['from_email'])
    @sent_on = Time.now
    @subject = subject
    @recipients = to.respond_to?(:email) ? to.email : to
    @from = from.respond_to?(:email) ? from.email : from
  end

  def welcome(account)
    # EAE added error log - not sure if this email is used
    logger.error("welcome email")
    setup_email(account.admin, "Welcome to #{AppConfig['app_name']}!")
    @body = { :account => account }
  end

  def trial_expiring(user, subscription)
    # EAE no trials for this site
    setup_email(user, 'Trial period expiring')
    @body = { :user => user, :subscription => subscription }
  end

  def charge_receipt(subscription_payment)
    # EAE added error log - not sure if this email is used
    # looks like it is automatic renewal
    logger.error("charge_receipt email")
    setup_email(subscription_payment.subscription.account.users.first, "Automatic Renewal Confirmation")
    @body = { :subscription => subscription_payment.subscription, :amount => subscription_payment.amount }
  end

  def setup_receipt(subscription_payment)
    # EAE added error log - not sure if this email is used
    logger.error("setup_receipt email")
    setup_email(subscription_payment.subscription.account.users.first, "Your YogaToday invoice")
    @body = { :subscription => subscription_payment.subscription, :amount => subscription_payment.amount }
  end

  def charge_failure(subscription)
    setup_email(subscription.account.users.first, "Your YogaToday renewal failed")
    @bcc = 'sales@yogatoday.com'
    @body = { :subscription => subscription }
  end

  def plan_changed(user, subscription)
    # EAE added error log - this should not be used
    # replaced by the 3 specific cases below
    logger.error("plan_changed email")
    subject "Your YogaToday plan has changed"
    recipients "#{user.name} <#{user.email}>"
    from "YogaToday <info@yogatoday.com>"
    body :subscription => subscription
  end

  def plan_changed_upgrade(user, subscription)
    logger.debug("plan_changed_upgrade email")
    subject "Your Yoga Today Subscription has been activated! (RECEIPT \##{subscription.id})"
    recipients "#{user.name} <#{user.email}>"
    from "YogaToday <info@yogatoday.com>"
    body :user => user, :subscription => subscription
  end

  def plan_changed_free(user)
    logger.debug("plan_changed_free email")
    subject "Welcome to Yoga Today!"
    recipients "#{user.name} <#{user.email}>"
    from "YogaToday <info@yogatoday.com>"
    body :user => user
  end

  def plan_changed_cancelled(user, subscription)
    logger.debug("plan_changed_cancelled email")
    subject "Your Yoga Today Subscription has been cancelled."
    recipients "#{user.name} <#{user.email}>"
    from "YogaToday <info@yogatoday.com>"
    last_payment = SubscriptionPayment.find(:last,
                                            :conditions => ["subscription_id = ?", subscription.id],
                                            :order => "created_at ASC")
    body :user => user, :subscription => subscription, :last_payment => last_payment
  end

  def password_reset(reset)
    setup_email(reset.user, 'Password Reset Request')
    @body = { :reset => reset }
  end
end
