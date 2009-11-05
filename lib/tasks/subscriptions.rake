namespace :subscriptions do
  desc "Charge due subscription accounts"
  task :charge_due_accounts => :environment do
    subscriptions = Subscription.find_due
    subscriptions.each do |subscription|
p subscription
      if subscription.subscription_plan.name != 'Free'
      if subscription.charge
	# comment out to avaoid double receipts
        #SubscriptionNotifier.deliver_charge_receipt(subscription.subscription_payments.last)
        puts "#{Time.now} Charged #{subscription.inspect}"
      else
        SubscriptionNotifier.deliver_charge_failure(subscription)
        puts "#{Time.now} Failed to charge #{subscription.inspect}"
      end      
      else
        puts "#{Time.now} Not charging free #{subscription.inspect}"
end
    end
  end
end
