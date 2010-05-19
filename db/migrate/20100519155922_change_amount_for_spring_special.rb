class ChangeAmountForSpringSpecial < ActiveRecord::Migration
  def self.up
    if sp = SubscriptionPlan.find_by_internal_name('spring_signup_special')
      sp.amount = 34.95
      sp.save
    end
  end

  def self.down
  end
end
