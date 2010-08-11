class SubscriptionPlan < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  # Associations
  belongs_to :transitions_to_subscription_plan, :class_name => 'SubscriptionPlan'

  # Validations
  # renewal_period is the number of months to bill at a time - default is 1
  validates_numericality_of :renewal_period, :only_integer => true, :greater_than => 0

  # Scopes

  # Extensions

  # Callbacks

  # Attributes


  def to_s
    "#{self.name} - #{number_to_currency(self.amount)} / month"
  end

  def to_param
    self.name
  end

  def is_trial?
    !self.trial_period.blank? && !self.trial_period_type.blank?
  end

  def is_free?
    self.name == 'Free'
  end

  def is_monthly_premium?
    self.name == 'Premium' && self.renewal_period == 1
  end

  def is_spring_special?
    self.name == 'Spring Signup Special' && self.renewal_period == 4
  end

  def is_annual_premium?
    self.name == 'Premium' && self.renewal_period == 12
  end

end
