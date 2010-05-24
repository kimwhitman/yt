class Subscription < ActiveRecord::Base
  # Associations
  belongs_to :account
  belongs_to :subscription_plan
  belongs_to :saved_subscription_plan, :class_name => 'SubscriptionPlan'
  has_many :subscription_payments, :dependent => :destroy
  has_many :billing_transactions, :as => :billing, :dependent => :destroy

  # Validations
  validates_numericality_of :renewal_period, :only_integer => true, :greater_than => 0
  validate_on_create :card_storage

  # Scopes
  named_scope :active, :conditions => ['state = ? AND last_attempt_successful != ?', 'active', false], :order => 'next_renewal_at ASC'
  named_scope :paid, :include => [:subscription_plan], :conditions => ['name != ?', 'Free']

  # Extensions

  # Callbacks
  before_create :set_renewal_at
  before_destroy :destroy_gateway_record!

  # Attributes
  attr_accessor :creditcard, :address
  attr_reader :response


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

    Rails.logger.info "DEBUG Attempting to store credit card details for Account ID: #{self.account_id}"
    Rails.logger.debug "DEBUG #{ gateway.class }"
    Rails.logger.debug "DEBUG Gateway options: #{gateway.options.inspect}"

    @response = if billing_id.blank?
      Rails.logger.debug "DEBUG Gateway store"
      gateway.store(creditcard, gw_options)
    else
      Rails.logger.debug "DEBUG Gateway update"
      gateway.update(billing_id, creditcard, gw_options)
    end
    Rails.logger.debug "DEBUG Response=#{ @response.inspect }"

    self.card_number = creditcard.display_number
    self.card_expiration = "%02d-%d" % [creditcard.expiry_date.month, creditcard.expiry_date.year]

    if @response.success?
      Rails.logger.info "DEBUG Successfully set credit card details for Account ID: #{self.account_id}"
      Rails.logger.info "DEBUG Response=#{@response.message}; Token=#{@response.token}"
      if set_billing(creditcard)
        Rails.logger.debug "DEBUG set_billing complete"
        true
      else
        Rails.logger.debug "DEBUG An error occured setting billing: #{errors.full_messages.join(',')}"
        Rails.logger.debug "DEBUG Gateway options: #{gateway.options.inspect}"
        false  # EAE this was missing - causing silent rejections
      end
    else
      Rails.logger.info "DEBUG Failed to set credit card details for Account ID: #{self.account_id}"
      Rails.logger.info "DEBUG Here's what the gateway said: #{@response.message}"
      errors.add_to_base(@response.message)
      false
    end
  end

  def charge_due
    # Does the subscription plan need to move to another plan when this one expires?
    if self.subscription_plan.transitions_to_subscription_plan
      new_plan = self.subscription_plan.transitions_to_subscription_plan
      puts "Subscription plan '#{ self.subscription_plan.name }' (#{ self.subscription_plan.id }) has expired. Transitioning to new plan '#{ new_plan.name }' (#{ new_plan.id })"
      self.saved_subscription_plan_id = self.subscription_plan_id
      self.subscription_plan_id = self.subscription_plan.transitions_to_subscription_plan_id
      self.renewal_period = new_plan.renewal_period
      self.amount = new_plan.amount
      self.save
      puts "New subscription plan (#{ self.subscription_plan.id }) Amount=$#{ self.amount }"
    end

    # Does this user have a Premium Free account, gained through reward points?
    # If so, revert them back to a free account
    if self.account.users.last.has_premium_free_subscription?
      self.subscription_plan_id = SubscriptionPlan.find_by_internal_name('free').id
      self.save
      puts "Has been moved back to a Free subscription"
    end

    if self.subscription_plan.internal_name != 'free'
      if self.charge
        # comment out to avoid double receipts
        #SubscriptionNotifier.deliver_charge_receipt(self.subscription_payments.last)
        p "#{Time.now} Charged"
        self.account.users.last.apply_ambassador_points!
        puts "#{ Time.now } Success"
      else
        SubscriptionNotifier.deliver_charge_failure(self)
        puts "#{ Time.now } Failed to charge"
      end
    else
      puts "#{ Time.now } Not charging - free"
    end
  end

  def charge
    puts "Name: #{ self.account.users.last.name } Plan: #{ self.subscription_plan } (ID=#{ self.subscription_plan.id })"
    logger.debug "DEBUG: Subscription charge Amount=#{ amount }"
    if amount == 0 || (@response = gateway.purchase(amount_in_pennies, self.billing_id)).success?
      logger.debug "DEBUG: Subscription charge success"

      # dates to be used by SubscriptionPayment
      start_date = self.next_renewal_at
      end_date   = self.next_renewal_at.advance(:months => self.renewal_period)
      update_attributes(:next_renewal_at => end_date, :state => 'active')

      logger.debug("DEBUG: Charge by adding new payment")
      subscription_payments.create(:account => account, :amount => amount,
        :transaction_id => @response.authorization,
        :start_date => start_date,
        :end_date => end_date,
        :payment_method => "Card #{ self.card_number }") unless amount == 0
      billing_transactions.create(:authorization_code => @response.authorization, :amount => (amount * 100)) unless amount == 0
      true
    else
      logger.debug "DEBUG: Subscription charge failure. amount=#{ amount_in_pennies } billing_id=#{ billing_id } response=#{ @response.inspect }"
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
    active.find(:all, :include => [:account, :subscription_plan], :conditions => ["subscription_plans.name != 'Free' AND DATE(next_renewal_at) = ?", Date.today])
  end

  def due?
    self.next_renewal_at.to_date == Date.today
  end

  def past_due?
    self.next_renewal_at.to_date > Date.today
  end

  def paypal?
    card_number == 'PayPal'
  end

  def destroy_gateway_record!(gw = gateway)
    return if billing_id.blank?

    if gw.class == ActiveMerchant::Billing::BogusGateway
      gw.unstore('1')
    else
      gw.unstore(billing_id)
    end

    self.card_number = nil
    self.card_expiration = nil
    self.billing_id = nil
    self.save
  end

  # TODO: needs unit test
  def upgrade_to_premium(_renewal_period = 1, ambassador_user_id = nil, notify_ambassador_of_reward = false)
    self.saved_subscription_plan_id = self.subscription_plan_id
    sp = SubscriptionPlan.find_by_name_and_renewal_period('Premium', _renewal_period)
    logger.debug "DEBUG Subscription upgrade: Name=#{ sp.name }"
    self.subscription_plan = sp
    self.amount = sp.amount
    self.renewal_period = _renewal_period
    self.save!
    self.account.users.last.set_ambassador!(ambassador_user_id, notify_ambassador_of_reward)
  end

  def upgrade_plan(subscription_plan, ambassador_user_id = nil, notify_ambassador_of_reward = false)
    logger.debug "DEBUG Subscription upgrade: Name=#{ subscription_plan.name }"
    self.saved_subscription_plan_id = self.subscription_plan_id
    self.subscription_plan = subscription_plan
    self.amount = subscription_plan.amount
    self.renewal_period = subscription_plan.renewal_period
    self.save!
    self.account.users.last.set_ambassador!(ambassador_user_id, notify_ambassador_of_reward)
  end

  def revert_plan!
    if self.saved_subscription_plan
      logger.debug "DEBUG Subscription reverting: Current=#{ self.subscription_plan.name } Previous=#{ self.saved_subscription_plan.name }"
      self.amount = self.saved_subscription_plan.amount
      self.renewal_period = self.saved_subscription_plan.renewal_period
      self.subscription_plan_id = self.saved_subscription_plan_id
      self.save!
      self.account.users.last.reset_ambassador!
    end
  end

  # TODO: needs unit test
  def downgrade_to_free
    self.saved_subscription_plan_id = self.subscription_plan_id
    self.saved_next_renewal_at = self.next_renewal_at
    sp = SubscriptionPlan.find_by_name('Free')
    self.subscription_plan = sp
    self.amount = sp.amount
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

    def set_billing(cc = nil)
      self.billing_id = @response.token unless @response.token.blank?

      if new_record?
        # =======================================================================================================
        # NOTE: This all looks like non-functional code in this part of the condition, and may need to be deleted
        # The code is always going into the 'else' part
        # =======================================================================================================
        if !next_renewal_at? || next_renewal_at < 1.day.from_now.at_midnight
          if subscription_plan.trial_period?
            logger.info("DEBUG Trial period #{ subscription_plan.trial_period }")
            self.next_renewal_at = Time.now.advance(:months => subscription_plan.trial_period)
            self.state = 'trial'
          else
            charge_amount = subscription_plan.setup_amount? ? subscription_plan.setup_amount : amount
            if amount == 0 || gateway.options[:test] == 'true' || (@response = gateway.purchase(charge_amount * 100, billing_id)).success?

              # dates to be used by SubscriptionPayment
              start_date = Time.now
              end_date   = Time.now.advance(:months => renewal_period)

              logger.debug("Set billing by adding new payment for new record")

              subscription_payments.build(:account => account, :amount => charge_amount,
                :transaction_id => @response.authorization,
                :setup => subscription_plan.setup_amount?,
                :start_date => start_date,
                :end_date => end_date)

              billing_transactions.build(:authorization_code => @response.authorization, :amount => (charge_amount * 100))

              self.state = 'active'
              self.next_renewal_at = end_date
            else
              restore_saved_plan
              errors.add_to_base(@response.message)
              return false
            end
          end
          self.save!
        end
      else
        # amount_changed? looks dangerous here,
        # but it will only be true when the user is upgrading their account...
        # ...or downgrading their account. But downgrades don't trigger set_billing.
        # And even if they did, they wouldn't cause a credit card charge.
        # -- ARRON WASHINGTON
        if !next_renewal_at? || next_renewal_at < 1.day.from_now.at_midnight || amount_changed?
          self.amount = subscription_plan.setup_amount? ? subscription_plan.setup_amount : subscription_plan.amount
          logger.debug("Amount = #{amount.to_s}")

          # To test rejected charge
          # if ((gateway.options[:test] == 'true') && card_number.include?('1111'))
          #   logger.debug("IN TEST REJECT")
          #   restore_saved_plan
          #   errors.add_to_base('invalid account')
          #   return false
          # end

          logger.debug("Attempting to charge card #{ amount_in_pennies } pennies")

          # support using BogusGateway when testing (based on config.yml)
          # transaction_id is calculated differently between gateways, so
          # this will get us a valid one
          # Purchase
          if amount > 0
            if gateway.class == ActiveMerchant::Billing::BogusGateway
              logger.debug "Using BogusGateway"
              @response = gateway.purchase(amount_in_pennies, cc)
              trans_id = @response.success? ? 1 : 'err'
            else
              @response = gateway.purchase(amount_in_pennies, billing_id)
              trans_id = @response.authorization
            end
            logger.debug("Response is #{ @response.inspect }")
          end

          if amount == 0 || @response.success? || gateway.options[:test] == 'true'
            self.state = 'active'
            # dates to be used by SubscriptionPayment
            start_date = self.next_renewal_at
            if self.subscription_plan.is_trial?
              end_date = Time.now.advance(self.subscription_plan.trial_period_type.to_sym => self.subscription_plan.trial_period)
            else
              end_date = Time.now.advance(:months => renewal_period)
            end

            logger.debug("Set billing by adding new payment for existing record")
            self.next_renewal_at = end_date
            self.save!

            subscription_payments.create(:account => account, :amount => amount,
              :transaction_id => trans_id,
              :start_date => start_date,
              :end_date => end_date,
              :payment_method => "Card #{ self.card_number }")

            if amount > 0
              logger.debug "DEBUG Adding BillingTransaction authorization_code=#{ trans_id } amount=#{ amount * 100 }"
              billing_transactions.create(:authorization_code => trans_id, :amount => (amount * 100))
            end
          else
            logger.debug "DEBUG Failed response=#{ @response.inspect }"
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
      @cc ||= ActiveMerchant::Billing::Base.gateway(AppConfig[RAILS_ENV]['gateway']).new(config_from_file('gateway.yml'))
    end

    def card_storage
      self.store_card(@creditcard, :billing_address => @address.to_activemerchant) if @creditcard && @address && card_number.blank?
    end

    def config_from_file(file)
      YAML.load_file(File.join(RAILS_ROOT, 'config', file))[RAILS_ENV].symbolize_keys
    end

    def card_expired?
      if !card_expiration.blank?
        begin
          month, year = card_expiration.split('-')
          date = Date.parse("#{year}-#{month}-#{01}")
          return date < Date.today
        rescue NoMethodError, ArgumentError
          return false
        end
      end
      false
    end

    def self.charge_due_accounts
      subscriptions = Subscription.find_due
      subscriptions.each do |subscription|
        subscription.charge_due
        puts "=================================================="
      end
      true
    end

    def charge_past_due_accounts
      subscriptions = Subscription.active.paid.find(:all, :conditions => {:next_renewal_at => (45.days.ago .. Date.today ) })
      subscriptions.each do |subscription|
        p subscription
        if subscription.charge
          puts "#{Time.now} Charged #{subscription.inspect}"
          subscription.update_attributes({:last_attempt_at => Time.now, :last_attempt_successful => true})
        else
          SubscriptionNotifier.deliver_charge_failure(subscription)
          puts "#{Time.now} Failed to charge #{subscription.inspect}"
          subscription.update_attributes({:last_attempt_at => Time.now, :last_attempt_successful => false})
        end
      end
    end
end
