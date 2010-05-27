class AddTrialFieldsToSubscriptionPlan < ActiveRecord::Migration
  def self.up
    #add_column :subscription_plans, :trial_period_type, :string
    #add_column :subscription_plans, :transitions_to_subscription_plan_id, :integer

    #add_index :subscription_plans, :transitions_to_subscription_plan_id

    SubscriptionPlan.reset_column_information

    SubscriptionPlan.create(:name => 'Spring Signup Special', :amount => 0,
      :trial_period => 14, :trial_period_type => 'days',
      :transitions_to_subscription_plan_id => SubscriptionPlan.find_by_name('Spring Signup Special').id)

    SubscriptionPlan.create(:name => 'Premium', :amount => 0,
      :trial_period => 14, :trial_period_type => 'days',
      :transitions_to_subscription_plan_id => SubscriptionPlan.find_by_name_and_renewal_period('Premium', 12).id)
  end

  def self.down
    SubscriptionPlan.find_by_name_and_trial_period('Spring Signup Special', 14).destroy
    SubscriptionPlan.find_by_name_and_trial_period('Premium', 14).destroy

    remove_index :subscription_plans, :transitions_to_subscription_plan_id

    remove_column :subscription_plans, :trial_period_type
    remove_column :subscription_plans, :transitions_to_subscription_plan_id
  end
end
