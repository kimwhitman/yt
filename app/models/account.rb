class Account < ActiveRecord::Base

  has_many :users
  has_one :admin, :class_name => "User", :conditions => { :admin => true }
  has_one :subscription, :dependent => :destroy
  has_many :subscription_payments, :dependent => :destroy

  validate_on_create :valid_user?
  validate_on_create :valid_plan?
  validate_on_create :valid_payment_info?
  validate_on_create :valid_subscription?

  attr_accessible :name, :user, :plan, :plan_start, :creditcard, :address
  attr_accessor :user, :plan, :plan_start, :creditcard, :address

  acts_as_paranoid

  def needs_payment_info?
    if new_record?
      AppConfig['require_payment_info_for_trials'] && @plan && @plan.amount > 0
    else
      self.subscription.needs_payment_info?
    end
  end

  def active?
    self.subscription.next_renewal_at >= Time.now
  end



  protected
    # An account must have an associated user to be the administrator
    def valid_user?
      if !@user
        errors.add_to_base("Missing user information")
      elsif !@user.valid?
        @user.errors.full_messages.each do |err|
          errors.add_to_base(err)
        end
      end
    end

    def valid_payment_info?
      if needs_payment_info?
        unless @creditcard && @creditcard.valid?
          errors.add_to_base("Invalid payment information")
        end

        unless @address && @address.valid?
          errors.add_to_base("Invalid address")
        end
      end
    end

    def valid_plan?
      errors.add_to_base("Invalid plan selected.") unless @plan
    end

    def valid_subscription?
      return if errors.any? # Don't bother with a subscription if there are errors already
      self.build_subscription(:plan => @plan, :next_renewal_at => @plan_start, :creditcard => @creditcard, :address => @address)
      if !subscription.valid?
        errors.add_to_base("Error with payment: #{subscription.errors.full_messages.to_sentence}")
        return false
      end
    end
end
