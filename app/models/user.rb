require 'digest/sha1'

class User < ActiveRecord::Base
  # Associations
  belongs_to :account, :dependent => :destroy
  has_many :playlist_videos, :dependent => :destroy
  has_many :purchases, :dependent => :destroy
  has_many :invites
  has_many :ambassador_invites

  # Validations
  validates_acceptance_of :agree_to_terms
  validates_presence_of     :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_uniqueness_of   :ambassador_name, :case_sensitive => false, :within => 3..12, :allow_nil => true, :allow_blank => false
  validates_inclusion_of :newsletter_format, :in => %w(html plain)
  validates_confirmation_of :email, :on => :create

  # Scopes

  # Extensions
  has_attached_file :photo,
    :default_url => "/images/user_yogi.png",
    :styles => { :small => '48x48#' },
    :default_style => :small

  # Callbacks
  before_save :encrypt_password
  before_save :store_old_email
  before_save :downcase_email
  before_save :initialize_confirmation_token
  after_save :setup_free_account
  after_save :setup_newsletter

  # Attributes
  attr_accessor :password
  attr_accessor :old_email
  attr_accessible :name, :email, :password, :password_confirmation,
    :wants_newsletter, :wants_promos, :photo, :photo_file_name,
    :photo_content_type, :photo_file_size, :city, :state, :country,
    :agree_to_terms, :newsletter_format, :email_confirmation, :ambassador_name


  def name
    # FIXME !read_attribute(:name).blank?? read_attribute(:name) : self.login
    !read_attribute(:name).blank?? read_attribute(:name) : "Anonymous"
  end
  def wants_newsletter=(value)
    write_attribute(:wants_newsletter,value)
    @newsletter_changed = true
  end
  # Authenticates a user by their email address and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    the_address = email
    unless the_address.nil?
      the_address.downcase!
    end
    u = find_by_email(the_address) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  def playlist(reload = false)
    if reload
      @playlist = UserPlaylist.new(self)
    else
      @playlist ||= UserPlaylist.new(self)
    end
  end

  def has_downgraded_to_free?
    (self.account.subscription.subscription_plan.name == 'Free') && had_paying_subscription?
  end

  # Does the user have a paying subscription right now?
  def has_paying_subscription?
    if self.account.subscription.subscription_plan.name != 'Free'
      if self.account.subscription.next_renewal_at.advance(:days => 1) > Time.now
        return true
      end
      return false
    else
      # give cancelled and expired to the end of their term with grace
      if self.had_paying_subscription?
        self.account.subscription_payments.each do |item|
          # grace period
          if item.created_at.advance(:days => 32) > Time.now
            return true
          end
        end
      end
      return false
    end
  end

  def has_active_card?
    has_paying_subscription? && !account.subscription.card_expired?
  end

  # Did the user at some point HAVE a paying subscription?
  def had_paying_subscription?
    self.account.subscription_payments.count > 0
  end

  #Set subscription price
  def cart_items_to_subscription_price
    carts = Cart.find(:all, :conditions => {:user_id => self.id})
    carts.each do |cart|
      cart.cart_items.each do |item|
        item.update_attributes(:amount => Money.new(299))
      end
    end
  end

  def cart_items_to_non_subscription_price
    carts = Cart.find(:all, :conditions => {:user_id => self.id})
    carts.each do |cart|
      cart.cart_items.each do |item|
        item.update_attributes(:amount => Money.new(399))
      end
    end
  end

  def newsletter_format=(format)
    if format.to_s == 'plain'
      self[:newsletter_format] = 'plain'
    else
      self[:newsletter_format] = 'html'
    end
  end

  # confirm a user's email
  def confirm_email!
    self.email_confirmed    = true
    self.confirmation_token = nil
    save(false)
  end

  def first_name
    self.name.split.first || ''
  end

  def ambassador_invite_with_default_body
    self.ambassador_invites.find(:first, :conditions => ["is_default_body_for_user = ?", true])
  end

  def redeem_points(redeemed_points)
    if redeemed_points <= self.points_current
      User.transaction do
        self.points_current -= redeemed_points
        self.points_used += redeemed_points

        subscription = self.account.subscription
        (1..redeemed_points).each do |point|
          start_date = subscription.next_renewal_at
          end_date = start_date.advance(:months => 1)

          subscription.next_renewal_at = end_date
          subscription.save

          self.account.subscription_payments << SubscriptionPayment.create(
            :subscription => self.account.subscription, :payment_method => SubscriptionPayment::REWARD_POINTS_PAYMENT_METHOD,
            :amount => 0, :start_date => start_date, :end_date => end_date)
        end

        self.save
        true
      end
    else
      false
    end
  end



  protected

    def store_old_email
      if email_changed?
        @old_email = email_change.last
      end
    end

    def initialize_confirmation_token
      generate_confirmation_token if new_record?
    end

    def generate_confirmation_token
      self.confirmation_token = encrypt("--#{Time.now.utc}--#{password}--")
    end

    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    # After filter
    def setup_newsletter
      return unless @newsletter_changed || !@old_email.blank?

      if Rails.env == 'production'
        if wants_newsletter
          ConstantContact.subscribe(self)
        else
          ConstantContact.unsubscribe(self)
        end
      end
      @newsletter_changed = false
    rescue Exception => e
      # In case the CC API doesn't want to talk to us right now.
      Rails.logger.info "Could not contact CC api: #{e}, #{e.backtrace}"
    end

    def setup_free_account
      return unless self.account.nil?
      self.build_account :name => "#{self.name}'s Yoga Today account",
        :user => self,
        :plan => SubscriptionPlan.find_by_name('Free'),
        :plan_start => DateTime.now
      self.account.full_domain = 'yogatoday.com'
      self.account.save!
      self.account_id = self.account.id
      self.save
    end

    def downcase_email
      self.email = self.email.downcase
    end
end
