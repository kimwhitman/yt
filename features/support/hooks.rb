Before do
  # create subscription plans
  plans = [
    { :name => 'Free',    :amount => 0,   :renewal_period => 1 },
    { :name => 'Premium', :amount => 10,  :renewal_period => 1 },
    { :name => 'Premium', :amount => 100, :renewal_period => 12 }
  ]
  plans.each { |plan| SubscriptionPlan.create(plan) }
end
