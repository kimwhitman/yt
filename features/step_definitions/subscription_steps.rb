Given /^the following subscription plans:$/ do |subscription_plans|
  subscription_plans.hashes.each do |hash|
    SubscriptionPlan.create!(hash)
  end
end
