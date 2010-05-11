namespace :subscriptions do
  desc "Charge due subscription accounts"
  task :charge_due_accounts => :environment do
    Subscription.charge_due_accounts
  end

  desc "Look for any un-renewed subscriptions and try again"
  task :charge_past_due_accounts => :environment do
    Subscription.charge_past_due_accounts
  end
end
