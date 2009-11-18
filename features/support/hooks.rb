Before do
  # create subscription plans
  plans = [
    { 'name' => 'Free',    'amount' => 0,  'user_limit' => 2 },
    { 'name' => 'Basic',   'amount' => 10, 'user_limit' => 5 },
    { 'name' => 'Premium', 'amount' => 30, 'user_limit' => nil }
  ]
  plans.each { |plan| SubscriptionPlan.create(plan) }
end
