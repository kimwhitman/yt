class AddFreePremiumSubscriptionPlan < ActiveRecord::Migration
  def self.up
    SubscriptionPlan.create(:name => 'Premium - Free', :internal_name => 'premium_monthly_free', :amount => 0,
     :renewal_period => 1)
  end

  def self.down
    SubscriptionPlan.find_by_internal_name('premium_monthly_free').destroy
  end
end
