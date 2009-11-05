require 'digest/sha1'
class Purchase < ActiveRecord::Base
  # Associations
  has_many :purchase_items, :dependent => :destroy
  has_one :billing_transaction, :as => :billing, :dependent => :destroy
  belongs_to :user
  # Attributes
  attr_accessor :card_expiration, :card_verification, :credit_card
  attr_reader :gateway_response
  STATUS_CODES = %w(new pending completed failed)

  # Validations
  validates_presence_of :first_name, :last_name, :email, :card_number, :card_type, :invoice_no, :transaction_code, :status
  validates_inclusion_of :status, :in => STATUS_CODES
  validates_uniqueness_of :invoice_no, :transaction_code
  #validates_associated :billing_transaction

  # Callbacks
  before_validation :generate_invoice_no, :set_status, :generate_transaction_code
  validate_on_create :verify_credit_card
  before_create :mask_card_number
  #after_create :send_purchase_confirmation

  def charge_card(shopping_cart)
    # All the code to round up the invoice total here.
    if self.status == 'pending'
      raise StandardError.new "This purchase is in still in the pending state; a way wicked internal error occured."
    end
    self.status = 'pending'
    Rails.logger.info "Beginning purchase."
    raise StandardError.new "Credit Card is invalid" unless credit_card.valid?
    if (RAILS_ENV == 'development')
      record_purchase(shopping_cart, true)
      Rails.logger.info("FAKE PURCHASE COMPLETE")
      self.status = 'complete'
      return true
    end
    gateway_opts = config_from_file('gateway.yml')
    gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(gateway_opts)
    Rails.logger.info "Attempting purchase (ID: #{self.id}) for #{sprintf("%.2f", shopping_cart.total.to_dollars)}"
    @gateway_response = gateway.purchase(shopping_cart.total.amount, credit_card)
    if @gateway_response.success? || @gateway_response.message == '(TESTMODE) This transaction has been approved'
      Rails.logger.info "The purchase (ID: #{self.id || 'unsaved'}) for #{sprintf("%.2f", shopping_cart.total.to_dollars)} has suceeded."
      record_purchase(shopping_cart)
      self.status = 'complete'
      true
    else
      Rails.logger.info "The purchase (ID: #{self.id || 'unsaved'}) for #{sprintf("%.2f", shopping_cart.total.to_dollars)} has failed."
      Rails.logger.info "Here was the message from the Authorize.net gateway: #{@gateway_response.message}"
      Rails.logger.info "Tried with the following options:: #{gateway.options.inspect}"
      self.status = 'failed'
      false
    end
  rescue Exception => e
    self.status = 'failed'
    Rails.logger.info "A critical error has occured during the purchasing routine: #{e.message}\n#{e.backtrace.join('\n')}"
    Rails.logger.info "Attempted to charge #{shopping_cart.total} with potential authorization ID #{@gateway_response.authorization}"
    # If the purchase went through, we need to void it -- ASAP!
    gateway.void(@gateway_response.authorization) if @gateway_response.authorization
    return false
  end

  def credit_card
    month, year = nil, nil
    if self.card_expiration
      month = self.card_expiration.month
      year = self.card_expiration.year
    end
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :first_name => self.first_name,
      :last_name => self.last_name,
      :number => self.card_number,
      :month => month, :year => year,
      :type => self.card_type,
      :verification_value => self.card_verification
    )
  end

  def reset_credit_card!
    @credit_card = nil
  end

  # Returns the total as dollars.
  def total
    self.purchase_items.inject(0.00) { |sum, pi| sum += pi.price_in_dollars }
  end

  def to_param
    # Let's use the invoice_no so nobody gets any bright ideas.
    self.invoice_no
  end

  private

  def record_purchase(cart, testmode = false)
    self.user_id = cart.user.id if cart.user
    Purchase.transaction do
      save!
      if (testmode)
        bt = self.build_billing_transaction(:authorization_code => "BOGUS", :amount => cart.total.amount)
      else
        bt = self.build_billing_transaction(:authorization_code => @gateway_response.authorization, :amount => cart.total.amount)
      end
      bt.save!
      cart.videos.each do |ci|
        purchase_item = purchase_items.build :purchase_type => ci.product_type,
          :price_in_cents => ci.amount.to_pennies,
          :name => ci.product_name,
          :purchased_item_id => ci.product_id
        purchase_item.save!
      end
    end
    send_purchase_confirmation
    true
  end

  protected

  def send_purchase_confirmation
    UserMailer.deliver_purchase_confirmation self
  end

  def verify_credit_card
    return true if credit_card.valid?
    credit_card.errors.full_messages.each { |msg| self.errors.add_to_base(msg) }
  end

  def mask_card_number
    self.card_number = credit_card.display_number
  end

  # Generate a unique invoice no.
  # We're doing it this way so that people won't make many mistakes if they're typing it by hand.
  # And it makes the nosey folk harder to dig around inside when combined with the transaction_code.
  def generate_invoice_no
    return true unless self.invoice_no.blank?
    # Style of: XXX-XXXX-DD ('digital download')
    # XXX = 3 numbers, random.
    # XXXX = NUMBER,LETTER,NUMBER,LETTER, random.
    # DD = DD (static) ('digital download')
    self.invoice_no = [rand(9), rand(9), rand(9), '-', rand(9), (rand(25) + 97).chr, rand(9), (rand(25) + 97).chr, '-', 'DD'].join
  end

  def generate_transaction_code
    return true unless self.transaction_code.blank?
    self.transaction_code = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{invoice_no}");
  end

  def set_status
    return true unless self.status.blank?
    self.status = 'new'
  end

  # Copied this from subscription.rb
  # Why no SaaS Railskit guy, why would we want to put this somewhere global?!
  def config_from_file(file)
    YAML.load_file(File.join(RAILS_ROOT, 'config', file))[RAILS_ENV].symbolize_keys
  end
end
