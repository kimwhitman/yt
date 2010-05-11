class AddAmbassadorColumnsToUsers2 < ActiveRecord::Migration
  def self.up
    add_column :users, :has_rewarded_ambassador, :boolean, :null => false, :default => false
    add_column :users, :notify_ambassador_of_reward, :boolean, :null => false, :default => false

    add_column :subscription_plans, :generates_ambassador_reward, :boolean, :null => false, :default => false
    add_column :subscription_plans, :internal_name, :string

    SubscriptionPlan.reset_column_information

    subscription_plan = SubscriptionPlan.find_by_name('Free')
    subscription_plan.internal_name = 'free'
    subscription_plan.generates_ambassador_reward = false
    subscription_plan.save

    subscription_plan = SubscriptionPlan.find_by_name('Basic')
    subscription_plan.internal_name = 'basic'
    subscription_plan.generates_ambassador_reward = false
    subscription_plan.save

    subscription_plan = SubscriptionPlan.find_by_name_and_renewal_period('Premium', 1)
    subscription_plan.internal_name = 'premium_monthly'
    subscription_plan.generates_ambassador_reward = false
    subscription_plan.save

    subscription_plan = SubscriptionPlan.find_by_name_and_renewal_period('Premium', 12)
    subscription_plan.internal_name = 'premium_annually'
    subscription_plan.generates_ambassador_reward = true
    subscription_plan.save

    subscription_plan = SubscriptionPlan.find_by_name_and_renewal_period('Spring Signup Special', 4)
    subscription_plan.internal_name = 'spring_signup_special'
    subscription_plan.generates_ambassador_reward = true
    subscription_plan.save

    subscription_plan = SubscriptionPlan.find_by_name_and_trial_period('Spring Signup Special', 14)
    subscription_plan.internal_name = 'spring_signup_special_trial'
    subscription_plan.generates_ambassador_reward = false
    subscription_plan.save

    subscription_plan = SubscriptionPlan.find_by_name_and_trial_period('Premium', 14)
    subscription_plan.internal_name = 'premium_annualy_trial'
    subscription_plan.generates_ambassador_reward = false
    subscription_plan.save
  end

  def self.down
    remove_column :users, :has_rewarded_ambassador
    remove_column :users, :notify_ambassador_of_reward

    remove_column :subscription_plans, :generates_ambassador_reward
    remove_column :subscription_plans, :internal_name
  end
end
