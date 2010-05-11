module UsersHelper

  # displays the period A SubscriptionPayment was billed for
  # previously start_date and end_date weren't available.
  # in these cases we'll use the monthly default
  def billing_period(subscription_payment)
    if subscription_payment.start_date.blank? || subscription_payment.end_date.blank?
      s = subscription_payment.created_at.strftime('%b %e, %Y')
      e = (subscription_payment.created_at + 1.month - 1.day).strftime('%b %e, %Y')
    else
      s = subscription_payment.start_date.strftime('%b %e, %Y')
      e = subscription_payment.end_date.strftime('%b %e, %Y')
    end
    [s, e].join(' - ').to_s
  end

  # $9.99 Monthly Unlimited Membership
  def membership_type
    if current_user.account.subscription.subscription_plan.amount > 0
      membership_type_amount = "$#{ current_user.account.subscription.subscription_plan.amount } "
    else
      membership_type_amount = ""
    end
    "#{ membership_type_amount }#{ current_user.account.subscription.subscription_plan.name } Membership"
  end

  def current_membership_period
    subscription_payment = current_user.account.subscription_payments.find(:first,
      :conditions => ['now() BETWEEN start_date AND end_date'])
    if subscription_payment
      billing_period(subscription_payment)
    else
      'n/a'
    end
  end

  def current_membership_amount
    subscription_payment = current_user.account.subscription_payments.find(:first,
      :conditions => ['now() BETWEEN start_date AND end_date'])
    if subscription_payment
      if subscription_payment.payment_method == SubscriptionPayment::REWARD_POINTS_PAYMENT_METHOD
        'FREE'
      else
        "$#{ subscription_payment.amount }"
      end
    else
      'n/a'
    end
  end

  def ambassador_navigation_links
    [{:title => 'Invite by E-mail', :path => ambassador_tools_invite_by_email_user_path(current_user) },
      {:title => 'Invite by Sharing', :path => ambassador_tools_invite_by_sharing_user_path(current_user)},
      {:title => 'My Invitations', :path => ambassador_tools_my_invitations_user_path(current_user)},
      {:title => 'My Reward', :path => ambassador_tools_my_rewards_user_path(current_user)},
      {:title => 'Help', :path => ambassador_tools_help_user_path(current_user)}
    ]
  end
end
