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

end
