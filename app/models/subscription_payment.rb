class SubscriptionPayment < ActiveRecord::Base
  REWARD_POINTS_PAYMENT_METHOD = 'Reward points'
  # Associations
  belongs_to :subscription
  belongs_to :account

  # Validations

  # Scopes

  # Extensions

  # Callbacks
  before_create :set_account
  after_create :send_receipt

  # Attributes


  def set_account
    self.account = subscription.account
  end

  def send_receipt
    return unless amount > 0
    if setup?
      SubscriptionNotifier.deliver_setup_receipt(self)
    else
      #SubscriptionNotifier.deliver_charge_receipt(self)
    end
    true
  end

  # The card number is not stored by itself. Instead it is preceded by some text. Don't ask me why...
  def get_card_number(digits = 0)
    if self.payment_method && self.payment_method.first(4) == 'Card'
      self.payment_method.split(' ').last.last(digits)
    end
  end
end
