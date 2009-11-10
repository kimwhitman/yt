module UsersHelper

  # displays the period A SubscriptionPayment was billed for
  # previously start_date and end_date weren't available.
  # in these cases we'll use the monthly default
  def billing_period(subscription_payment)
    if subscription_payment.start_date.blank? || subscription_payment.end_date.blank?
      s = subscription_payment.created_at.strftime('%d-%b-%y')
      e = (subscription_payment.created_at + 1.month - 1.day).strftime('%d-%b-%y')
    else
      s = subscription_payment.start_date.strftime('%d-%b-%y')
      e = subscription_payment.end_date.strftime('%d-%b-%y')
    end
    [s, e].join(' - ').to_s
  end
end
