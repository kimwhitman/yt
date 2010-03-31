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
          subscription.update_attributes({:last_attempt_at => Time.now, :last_attempt_successful => true})
        else
          SubscriptionNotifier.deliver_charge_failure(subscription)
          puts "#{Time.now} Failed to charge #{subscription.inspect}"
          subscription.update_attributes({:last_attempt_at => Time.now, :last_attempt_successful => false})
        end
      else
        puts "#{Time.now} Not charging free #{subscription.inspect}"
      end
    end

  end

  desc "Look for any un-renewed subscriptions and try again"
  task :charge_past_due_accounts => :environment do
    subscriptions = Subscription.active.paid.find(:all, :conditions => {:next_renewal_at => (30.days.ago .. Date.today ) })

    subscriptions.each do |subscription|
      p subscription
      if subscription.charge
        puts "#{Time.now} Charged #{subscription.inspect}"
        subscription.update_attributes({:last_attempt_at => Time.now, :last_attempt_successful => true})
      else
        SubscriptionNotifier.deliver_charge_failure(subscription)
        puts "#{Time.now} Failed to charge #{subscription.inspect}"
        subscription.update_attributes({:last_attempt_at => Time.now, :last_attempt_successful => false})
      end
    end
  end
end
