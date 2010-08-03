require 'digest/sha1'

class User < ActiveRecord::Base
  # Associations
  belongs_to :account, :dependent => :destroy
  has_many :playlist_videos, :dependent => :destroy
  has_many :purchases, :dependent => :destroy
  has_many :invites
  has_many :ambassador_invites
  has_one :share_url
  belongs_to :ambassador, :class_name => 'User'

  # Validations
  validates_acceptance_of :agree_to_terms
  validates_presence_of     :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_uniqueness_of   :ambassador_name, :case_sensitive => false, :within => 3..12, :allow_nil => true
  validates_inclusion_of :newsletter_format, :in => %w(html plain)
  validates_confirmation_of :email, :on => :create

  # Scopes
  named_scope :ambassadors, :conditions => [ 'ambassador_name IS NOT NULL' ]

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
  before_save :strip_ambassador_name
  before_save :validate_ambassador_name
  before_save :send_new_ambassador_mail
  after_save :setup_free_account
  after_save :setup_newsletter
  after_update :setup_share_url
  after_create :add_to_mailchimp
  after_save :analyse_for_mailchimp_group_changes

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

  def subscription
    self.account ? self.account.subscription : nil
  end

  def subscription_plan
    self.account && self.account.subscription ? self.account.subscription.subscription_plan : nil
  end

  def subscription_plan_name
    if self.account && self.account.subscription && self.account.subscription && self.account.subscription.subscription_plan
      self.account.subscription.subscription_plan.name
    else
      ''
    end
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

  def has_free_subscription?
    self.account.subscription.subscription_plan.internal_name == 'free'
  end

  def has_premium_free_subscription?
    self.account.subscription.subscription_plan.internal_name == 'premium_monthly_free'
  end

  def has_active_card?
    has_paying_subscription? && !account.subscription.card_expired?
  end

  def last_payment
    self.account.subscription.subscription_payments.find(:first, :order => 'created_at DESC')
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
          # If this is a user with a free account then we need to change their subscription plan
          if self.has_free_subscription?
            subscription.subscription_plan_id = SubscriptionPlan.find_by_internal_name('premium_monthly_free').id
            start_date = Date.today
          else
            start_date = subscription.next_renewal_at
          end
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

  def set_ambassador!(ambassador_user_id, notify)
    # If the user has an ambassador id and a paid plan then associate the two users
    unless ambassador_user_id.nil?
      #if self.has_paying_subscription?
        self.ambassador = User.find(ambassador_user_id)
        self.notify_ambassador_of_reward = true if notify
        self.save
      #end
    else
      false
    end
  end

  def reset_ambassador!
    # Only allow an ambassador id to be reset if there are no previous payments
    # This prevents somebody from ever having multiple ambassador points awarded out
    unless ambassador_id.nil?
      if self.account.subscription.subscription_payments.empty?
        self.ambassador_id = nil
        self.save
      end
    end
  end

  def apply_ambassador_points!
    if self.ambassador && !self.has_rewarded_ambassador? && self.account.subscription.subscription_plan.generates_ambassador_reward?
      logger.debug "DEBUG: Applying ambassador points #{ self.ambassador.id } #{ !self.has_rewarded_ambassador? } #{ self.account.subscription.subscription_plan.generates_ambassador_reward? }"
      self.ambassador.increment!(:points_earned)
      self.ambassador.increment!(:points_current)
      self.ambassador.increment!(:successful_referrals_count)
      self.ambassador.increment!(:points_earned_since_last_login)
      if self.notify_ambassador_of_reward?
        UserMailer.deliver_ambassador_reward_notification(ambassador, self)
      end
      self.has_rewarded_ambassador = true
      self.save
      logger.debug "DEBUG: Applied #{ self.ambassador.inspect }"
    end
  end

  def membership_price
    if self.account.subscription.subscription_plan.is_trial?
      subscription_plan = self.account.subscription.subscription_plan.transitions_to_subscription_plan
    else
      subscription_plan = self.account.subscription.subscription_plan
    end
    subscription_plan.amount
  end

  def ambassador_referrals(scoped_to = nil)
    users = User.scoped :joins => "INNER JOIN accounts ON accounts.id = users.account_id
      INNER JOIN subscriptions ON subscriptions.account_id = accounts.id
      INNER JOIN subscription_plans ON subscription_plan_id = subscription_plans.id"

    case scoped_to
      when 'paid'
        users = users.scoped :conditions => [ "subscription_plans.name = 'free'" ]
      when 'free'
        users = users.scoped :conditions => [ "subscription_plans.name != 'free'" ]
    end

    users = users.scoped :conditions => [ 'users.ambassador_id = ?', self.id ]
  end

  def add_to_mailchimp(list_name = "Members")
    begin
      # http://github.com/bgetting/hominid
      hominid = Hominid::Base.new({:api_key => MAILCHIMP_API_KEY})
      hominid.subscribe(hominid.find_list_id_by_name(list_name), self.email, {:FNAME => self.name, :LNAME => ''}, {:email_type => 'html'})
      self.mailchimp_id = hominid.member_info(MAILCHIMP_MEMBERS_LIST_ID, self.email)["id"]




      # Add to a group for this list?
      #groups = hominid.groups(hominid.find_list_id_by_name('Members'))
      #hominid.update_member(hominid.find_list_id_by_name('Members'), 'imogene.lesch@lueilwitz.ca', { :INTERESTS => "Regular\,Ambassador invited" })
      #hominid.update_member(hominid.find_list_id_by_name('Members'), 'imogene.lesch@lueilwitz.ca', { :INTERESTS => "Regular" }, 'html', true)

      #groupings = hominid.groupings(hominid.find_list_id_by_name('Members'))
      #hominid.update_member(hominid.find_list_id_by_name('Members'), 'imogene.lesch@lueilwitz.ca', { :GROUPINGS => "Regular" }, 'html', true)



    rescue Exception => e
      ErrorMailer.deliver_error(e, :user_id => self.id)
    end
  end

  def assign_mailchimp_groups
    # NOTE: Any changes to the group names in Mailchimp has to be reflected here, or these group additions will fail
    # Free Members
    #   Regular Free Members
    #   Free Members by Ambassador Invitation
    # Class Download Customers
    #   Class Download Customers
    #
    # Ambassadors
    #   Ambassadors
    #
    # Paid Members
    #   Monthly recurring subscribers
    #   4 month prepaid subscribers
    #   1 year prepaid subscribers
    #   All Paid Members by Ambassador Invitation

    begin
      groups = []

      groups << 'Ambassadors' if self.ambassador_name

      if self.account.subscription.subscription_plan.is_free?
        groups << 'Free Members by Ambassador Invitation' if self.ambassador_id
        groups << 'Regular Free Members' if self.ambassador_id.blank?
      end

      if !self.account.subscription.subscription_plan.is_free?
        groups << 'All Paid Members by Ambassador Invitation' if self.ambassador_id
        groups << 'Monthly recurring subscribers'
        groups << '4 month prepaid subscribers'
        groups << '1 year prepaid subscribers'
      end

      hominid.update_member(hominid.find_list_id_by_name('Members'), self.email, { :GROUPINGS => groups.join('\,') }, 'html', true)

    rescue Exception => e
      ErrorMailer.deliver_error(e, :user_id => self.id)
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

    def setup_share_url
      if self.share_url.blank? && !self.ambassador_name.blank?
        self.create_share_url(:destination => "http://#{ HOST }/get-started-today?ambassador=#{ self.ambassador_name }")
      end
    end

    def downcase_email
      self.email = self.email.downcase
    end

    def strip_ambassador_name
      self.ambassador_name = self.ambassador_name.strip unless self.ambassador_name.nil?
    end

    def validate_ambassador_name
      # We allow nil values for ambassador name, but not empty strings
      false if self.ambassador_name == ''
    end

    def send_new_ambassador_mail
      if self.ambassador_name_changed?
        UserMailer.deliver_new_ambassador(self)
      end
    end

    def analyse_for_mailchimp_group_changes
      if self.ambassador_name_changed? || self.ambassador_id_changed?
        self.assign_mailchimp_groups
      end
    end
end
