class AddSubscriptionPlan < ActiveRecord::Migration
  def self.up
    SubscriptionPlan.create(:name => 'Spring Signup Special', :renewal_period => 4, :amount => 34.95, :trial_period => 0)
  end

  def self.down
    subscription_plan = SubscriptionPlan.find_by_name('Spring Signup Special')
  end
end
