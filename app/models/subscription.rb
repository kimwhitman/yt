class Subscription < ActiveRecord::Base
  belongs_to :account
  belongs_to :subscription_plan
  has_many :subscription_payments, :dependent => :destroy
  has_many :billing_transactions, :as => :billing, :dependent => :destroy

  before_create :set_renewal_at
  before_destroy :destroy_gateway_record!

  attr_accessor :creditcard, :address
  attr_reader :response

  # renewal_period is the number of months to bill at a time
  # default is 1
  validates_numericality_of :renewal_period, :only_integer => true, :greater_than => 0
  validate_on_create :card_storage

  def plan=(plan)
    [:amount, :user_limit, :renewal_period].each do |f|
      self.send("#{f}=", plan.send(f))
    end
    self.subscription_plan = plan
    self.state = 'active' unless plan.amount > 0
  end

  def trial_days
    (self.next_renewal_at.to_i - Time.now.to_i) / 86400
  end

  def amount_in_pennies
    (amount * 100).to_i
  end

  def store_card(creditcard, gw_options = {})
    # Clear out payment info if switching to CC from PayPal
    destroy_gateway_record(paypal) if paypal?
    Rails.logger.info "Attempting to store credit card details for Account ID: #{self.account_id}"
    @response = if billing_id.blank?
      gateway.store(creditcard, gw_options)
    else
      gateway.update(billing_id, creditcard, gw_options)
    end

    self.card_number = creditcard.display_number
    self.card_expiration = "%02d-%d" % [creditcard.expiry_date.month, creditcard.expiry_date.year]

    if @response.success?
      Rails.logger.info "Successfully set credit card details for Account ID: #{self.account_id}"
      Rails.logger.info "MESSAGE: #{@response.message}; TOKEN: #{@response.token}"
      if set_billing
        true
      else
        Rails.logger.info "An error occured setting billing: #{errors.full_messages.join(',')}"
        Rails.logger.info "Gateway options: #{gateway.options.inspect}"
        false  # EAE this was missing - causing silent rejections
      end
    else
      Rails.logger.info "Failed to set credit card details for Account ID: #{self.account_id}"
      Rails.logger.info "Here's what the gateway said: #{@response.message}"
      errors.add_to_base(@response.message)
      false
    end
  end

  def charge
    if amount == 0 || (@response = gateway.purchase(amount_in_pennies, self.billing_id)).success?
      update_attributes(:next_renewal_at => self.next_renewal_at.advance(:months => self.renewal_period), :state => 'active')
      subscription_payments.create(:account => account, :amount => amount, :transaction_id => @response.authorization) unless amount == 0
      billing_transactions.create(:authorization_code => @response.authorization, :amount => (amount * 100)) unless amount == 0
      true
    else
      errors.add_to_base(@response.message)
      false
    end
  end

  def start_paypal(return_url, cancel_url)
    if (@response = paypal.setup_authorization(:return_url => return_url, :cancel_return_url => cancel_url, :description => AppConfig['app_name'])).success?
      paypal.redirect_url_for(@response.params['token'])
    else
      errors.add_to_base("PayPal Error: #{@response.message}")
      false
    end
  end

  def complete_paypal(token)
    if (@response = paypal.details_for(token)).success?
      if (@response = paypal.create_billing_agreement_for(token)).success?
        # Clear out payment info if switching to PayPal from CC
        destroy_gateway_record(cc) unless paypal?

        self.card_number = 'PayPal'
        self.card_expiration = 'N/A'
        set_billing
      else
        errors.add_to_base("PayPal Error: #{@response.message}")
        false
      end
    else
      errors.add_to_base("PayPal Error: #{@response.message}")
      false
    end
  end

  def needs_payment_info?
    self.card_number.blank? && self.subscription_plan.amount > 0
  end

  def self.find_expiring_trials(renew_at = 7.days.from_now)
    find(:all, :include => :account, :conditions => { :state => 'trial', :next_renewal_at => (renew_at.beginning_of_day .. renew_at.end_of_day) })
  end

  def self.find_due_trials(renew_at = Time.now)
    find(:all, :include => :account, :conditions => { :state => 'trial', :next_renewal_at => (renew_at.beginning_of_day .. renew_at.end_of_day) }).select {|s| !s.card_number.blank? }
  end

  def self.find_due(renew_at = Time.now)
    find(:all, :include => :account, :conditions => { :state => 'active', :next_renewal_at => (renew_at.beginning_of_day .. renew_at.end_of_day) })
  end

  def paypal?
    card_number == 'PayPal'
  end

  def destroy_gateway_record!(gw = gateway)
    return if billing_id.blank?
    gw.unstore(billing_id)
    self.card_number = nil
    self.card_expiration = nil
    self.billing_id = nil
    self.save
  end

  def upgrade_to_premium
    self.saved_subscription_plan_id = self.subscription_plan_id
    self.subscription_plan_id = SubscriptionPlan.find_by_name('Premium').id
    self.save!
  end

  def downgrade_to_free
    self.saved_subscription_plan_id = self.subscription_plan_id
    self.saved_next_renewal_at = self.next_renewal_at
    self.subscription_plan_id = SubscriptionPlan.find_by_name('Free').id
    self.save!
  end

  protected

  def restore_saved_plan
    if (!self.saved_subscription_plan_id.nil?)
      logger.debug("restoring saved plan = #{self.saved_subscription_plan_id}")
      self.subscription_plan_id = self.saved_subscription_plan_id
      self.saved_subscription_plan_id = nil
      self.save!
    else
    end
  end

  def set_billing
    self.billing_id = @response.token unless @response.token.blank?

    if new_record?
      if !next_renewal_at? || next_renewal_at < 1.day.from_now.at_midnight
        if subscription_plan.trial_period?
          logger.info("in trial")
          self.next_renewal_at = Time.now.advance(:months => subscription_plan.trial_period)
        else
          charge_amount = subscription_plan.setup_amount? ? subscription_plan.setup_amount : amount
          if amount == 0 || gateway.options[:test] == 'true' || (@response = gateway.purchase(charge_amount * 100, billing_id)).success?
            subscription_payments.build(:account => account, :amount => charge_amount, :transaction_id => @response.authorization, :setup => subscription_plan.setup_amount?)
            billing_transactions.build(:authorization_code => @response.authorization, :amount => (charge_amount * 100))
            self.state = 'active'
            self.next_renewal_at = Time.now.advance(:months => renewal_period)
          else
            restore_saved_plan
            errors.add_to_base(@response.message)
            return false
          end
        end
      end
    else
      # amount_changed? looks dangerous here,
      # but it will only be true when the user is upgrading their account...
      # ...or downgrading their account. But downgrades don't trigger set_billing.
      # And even if they did, they wouldn't cause a credit card charge.
      # -- ARRON WASHINGTON
      logger.info("ARRON WASHINGTON")
      if !next_renewal_at? || next_renewal_at < 1.day.from_now.at_midnight || amount_changed?
        self.amount = subscription_plan.setup_amount? ? subscription_plan.setup_amount : subscription_plan.amount
        logger.info("amount = #{amount.to_s}")
        # To test rejected charge
        if ((gateway.options[:test] == 'true') && card_number.include?('1111'))
          logger.debug("IN TEST REJECT")
          restore_saved_plan
          errors.add_to_base('invalid account')
          return false
        end
        if amount == 0 || gateway.options[:test] == 'true' || (@response = gateway.purchase(amount_in_pennies, billing_id)).success?
          self.state = 'active'
          self.next_renewal_at = Time.now.advance(:months => renewal_period)
          self.save!
          subscription_payments.create(:account => account, :amount => amount, :transaction_id => @response.authorization)
          billing_transactions.create(:authorization_code => @response.authorization, :amount => (amount * 100))
        else
          restore_saved_plan
          errors.add_to_base(@response.message)
          return false
        end
      else
        self.state = 'active'
      end
      self.save!
    end

    true
  end

  def set_renewal_at
    return if self.subscription_plan.nil? || self.next_renewal_at
    self.next_renewal_at = Time.now.advance(:months => self.renewal_period)
  end

  def validate_on_update
    return unless self.subscription_plan.updated?
  end

  def gateway
    paypal? ? paypal : cc
  end

  def paypal
    @paypal ||=  ActiveMerchant::Billing::Base.gateway(:paypal_express_reference_nv).new(config_from_file('paypal.yml'))
  end

  def cc
    @cc ||= ActiveMerchant::Billing::Base.gateway(AppConfig['gateway']).new(config_from_file('gateway.yml'))
  end

  def card_storage
    self.store_card(@creditcard, :billing_address => @address.to_activemerchant) if @creditcard && @address && card_number.blank?
  end

  def config_from_file(file)
    YAML.load_file(File.join(RAILS_ROOT, 'config', file))[RAILS_ENV].symbolize_keys
  end
end
