require 'gift_card_service/api'

class UsersController < ApplicationController
  ssl_required :billing if RAILS_ENV == 'production'

  skip_filter :verify_authenticity_token, :only => [:check_login, :check_email]

  before_filter :login_required,
    :except => [
      :change_ambassador,
      :notify_ambassador,
      :signup,
      :create,
      :new,
      :special_message,
      :no_special_message,
      :check_email,
      :subscription,
      :select_ambassador,
      ]

  before_filter :setup_ambassador, :only => [:ambassador_tools_invite_by_email, :ambassador_tools_widget_invite_by_email]
  before_filter :fetch_ambassador, :only => [:new, :create, :select_ambassador, :billing]
  before_filter :setup_ambassador_email, :only => [:ambassador_tools_widget_invite_by_email, :ambassador_tools_invite_by_email]

  before_filter :ensure_not_logged_in, :only => :new
  before_filter :check_gift_card_code, :determine_membership_type, :only => [:new, :create]
  before_filter :setup_user, :only => :new

  def signup
    @user = User.new

    if params[:gift_card_code]
      redirect_to new_user_path(:gift_card_code => params[:gift_card_code])
    end
  end

  def new
    @creditcard = ActiveMerchant::Billing::CreditCard.new(params[:creditcard])
    @date = Date.today
  end

  def create
    @user = User.new(params[:user])
    @creditcard = ActiveMerchant::Billing::CreditCard.new(params[:creditcard])

    begin
      @date = Date.parse("#{@creditcard.month}/#{@creditcard.year}")
    rescue ArgumentError
      @date = Date.parse("Jan #{Date.today.year}")
    end

    if @user.valid? && @membership_type != 'free'

      # create subscription

      @address = SubscriptionAddress.new(:first_name => @creditcard.first_name,
                                         :last_name  => @creditcard.last_name)

      if @user.valid? && @creditcard.valid? && @address.valid?

        @user.membership_type = @membership_type

        ActiveRecord::Base.transaction do

          @user.save

          if @gift_card && @gift_card.valid?

            soap_endpoint = 'http://yogatodayws.complemar.com/Service1.asmx'
            namespace     = 'http://complemar.com/'
            client        = GiftCardService::API.new(soap_endpoint, namespace)

            # don't use card service when in dev mode. Instead check against 2 cards
            if Rails.env == 'development'
              result = ['1', '2'].include? @gift_card.serial_number
            else
              # FIXME: what if this fails?
              result = client.redeem(@gift_card.serial_number, @gift_card.balance)
            end
            
            if result && @user.membership_type == 'prepaid'
              time = Time.now.advance(:months => 12)
            elsif result && @user.membership_type == 'monthly'
              time = Time.now.advance(:months => 1)
            else
              logger.fatal "Gift Card Redemption unsuccessful. #{@gift_card.inspect}"
              time = Time.now
            end

            @user.account.subscription.update_attribute(:next_renewal_at, time)
          end
          
          if @user.membership_type == 'prepaid' && apply_ambassador
            @user.account.subscription.update_attribute(:next_renewal_at, Time.now.advance(:weeks => 2))
            sp = SubscriptionPlan.find_by_internal_name('premium_annualy_trial')
            @user.account.subscription.plan = sp
          end

          @user.account.subscription.renewal_period = @user.account.plan.renewal_period
          @user.account.subscription.save
          
          if @user.account.subscription.store_card(@creditcard, :billing_address => @address.to_activemerchant, :ip => request.remote_ip)
            logger.info "Subscription success!"
          else
            @user.errors.add_to_base "We were unable to obtain account authorization"
            errors = @user.account.subscription.errors.full_messages
            logger.info "Subscription Error: #{errors}"
            flash[:error_messages] = errors.join("<br/>")
            raise ActiveRecord::Rollback
          end
        end
      else
        @creditcard.errors.full_messages.each do |message|
          @user.errors.add_to_base message
        end

        @address.errors.full_messages.each do |message|
          @user.errors.add_to_base message
        end

        if @user.account
          @user.account.subscription.errors.full_messages.each do |message|
            @user.errors.add_to_base message
          end
        end

        errors = @creditcard.errors.full_messages + @address.errors.full_messages

        logger.debug("ERRORS: #{errors}")

        flash[:error_messages] = errors.join("<br/>")
      end
      
    end

    if @user.errors.count == 0 && @user.save

      if @membership_type == 'free'
        UserMailer.deliver_welcome(@user) 
        apply_ambassador
      end

      self.current_user = @user

      respond_to do |format|
        format.html { render :action => "welcome" }
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
      end
    end
  end

  def update
    if params[:user][:password] == ";9p=4-32"
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    current_user.attributes = params[:user]

    if current_user.ambassador_name_changed?
      flash[:success] = "Welcome to the Progam, Ambassador #{ current_user.ambassador_name }. Your ID is now ready to share."
    end

    if current_user.save
      respond_to do |format|
        format.html do
          flash[:user_notice] = "<span style='font-size: 14px; color: #488A1A'>Your changes have been saved.</span>" if flash[:success].blank?
          redirect_to profile_user_url(current_user)
        end
      end
    else
      respond_to do |format|
        format.html do
          flash[:user_notice] = "<span style='font-size: 14px; color: #aa0000'>There was an error updating your profile.</span>"
          current_user.reload
          redirect_to profile_user_url(current_user)
        end
      end
    end
  end

  def select_ambassador_name
    @ambassador_name = params[:user][:ambassador_name]
    case params[:redirect_to]
      when 'ambassador-details'
        redirect_to '/ambassador-details/?verify_ambassador_name=' + @ambassador_name
      else
        redirect_to profile_user_path(current_user, :verify_ambassador_name => @ambassador_name)
    end
  end

  def profile
    @current_user.country = current_user.country.nil? ? "United States" : current_user.country
  end

  # Member actions
  def billing
    @user = current_user
    @user.attributes = params[:user]
    # @user.add_to_base("You must agree to Membership Terms and Details") unless @user.agree_to_terms?
    @creditcard = ActiveMerchant::Billing::CreditCard.new params[:creditcard]

    if request.get? && Rails.env == 'development'
      @creditcard.number             = '1'
      @creditcard.verification_value = '123'
      #@creditcard.year              = Time.now.year + 1
      @creditcard.first_name         = 'John'
      @creditcard.last_name          = 'Smith'
      @user.agree_to_terms           = 1
    end

    begin
      @date = Date.parse("#{@creditcard.month}/#{@creditcard.year}")
    rescue ArgumentError
      @date = Date.parse("Jan #{Date.today.year}")
    end

    if !params[:membership].blank? && params[:membership] == 'free' && request.put?
      if @user.has_paying_subscription?
        flash[:notice] = "If you wish to cancel your membership, please click 'Cancel Membership' on the right side of the screen"
        @billing_cycle = @user.account.subscription.renewal_period.to_s
        return
      end
      redirect_to profile_user_url(current_user)
      return
    end

    if !params[:membership].blank? && %w(free 1 12).include?(params[:membership])
      @billing_cycle = params[:membership]
    elsif @user.has_paying_subscription?
      @billing_cycle = @user.account.subscription.subscription_plan.name #.renewal_period.to_s
    else
      # GB 5/11/10 Not allowing a default plan selection anymore as it can be confusing
      # Validation now also ensures that a plan has been selected
      #@billing_cycle = '1'
    end

    if !params[:membership].blank? && ['Premium Trial'].include?(params[:membership])
      @billing_cycle = 'Premium Trial'
      @subscription_plan = SubscriptionPlan.find_by_name_and_trial_period('Premium', 14)
    end

    if !params[:membership].blank? && ['Spring Signup Special Trial'].include?(params[:membership])
      @billing_cycle = 'Spring Signup Special Trial'
      @subscription_plan = SubscriptionPlan.find_by_name_and_trial_period('Spring Signup Special', 14)
    end

    if !params[:membership].blank? && ['Spring Signup Special'].include?(params[:membership])
      @billing_cycle = 'Spring Signup Special'
      @subscription_plan = SubscriptionPlan.find_by_name_and_renewal_period('Spring Signup Special', 4)
    end

    # BILLING SUBMISSION
    if request.post? || request.put?
      @address = SubscriptionAddress.new(:first_name => @creditcard.first_name,
        :last_name => @creditcard.last_name)

      if valid_billing?
        account_upgrade = !@user.has_paying_subscription?

        # Changing to a paid plan
        if @subscription_plan
          @user.account.subscription.upgrade_plan(@subscription_plan, cookies[:ambassador_user_id])
        else
          @user.account.subscription.upgrade_to_premium(@billing_cycle.to_i, cookies[:ambassador_user_id])
        end
        @user.account.subscription.update_attributes(:is_cancelled => false)

        migrate_cart!

        if @user.account.subscription.store_card(@creditcard, :billing_address => @address.to_activemerchant, :ip => request.remote_ip)
          if account_upgrade
            @user.reload # Out with the old, in with the new.
            @current_account = @user.account # EAE instance variable was not set to new account
            SubscriptionNotifier.deliver_plan_changed_upgrade(@user, @user.account.subscription)
            render :action => 'subscription_thank_you'
          else
            flash[:notice] = "Your billing information has been updated."# unless account_upgrade
            redirect_to billing_user_url(@user)
          end
        else
          @user.errors.add_to_base "We were unable to obtain account authorization"
          errors = @user.account.subscription.errors.full_messages
          logger.info "Subscription Error: #{errors}"
          flash[:error_messages] = errors.join("<br/>")
          # GB 5/19/10: Adding a revert so that we do not end up with people having access to plans that
          # they have not paid for
          @user.account.subscription.revert_plan!
          @user.account.subscription.reload
          @user.reload
        end
      else
        @creditcard.errors.full_messages.each do |message|
          @user.errors.add_to_base message
        end

        @address.errors.full_messages.each do |message|
          @user.errors.add_to_base message
        end

        @user.account.subscription.errors.full_messages.each do |message|
          @user.errors.add_to_base message
        end

        errors = @creditcard.errors.full_messages + @address.errors.full_messages + @user.account.subscription.errors.full_messages
        if @billing_cycle.nil? && @subscription_plan.nil?
          errors << "You must select a membership type."
          @user.errors.add_to_base "You must select a membership type."
        end
        logger.debug "DEBUG: Subscription Error: #{ errors.join("<br/>") }"
        flash[:error_messages] = errors.join("<br/>")
      end

    end
  end

  def billing_history
    @user = current_user

    if @user.has_paying_subscription? && !@user.has_active_card?
        flash[:notice] = "You credit card on file expired on #{@user.account.subscription.card_expiration}. Please update it in Payment info section"
    end
  end

  def cancel_membership
    return unless request.post?

    unless params[:accept_cancel_terms] == "1"
      flash[:notice] = "You must agree to cancel your membership."
      render :action => 'cancel_membership'
    end

    @subscription = Subscription.find(current_user.account.subscription.id)

    #@subscription.downgrade_to_free
    #current_user.cart_items_to_non_subscription_price
    @subscription.update_attributes(:is_cancelled => true, :cancelled_at => Time.now)
    @subscription.destroy_gateway_record!
    @subscription.save!
    SubscriptionNotifier.deliver_plan_changed_cancelled(current_user, @subscription)
    current_user.reload

    render :action => 'subscription_cancelled'
  end

  def special_message
    render :partial => 'special_message'
  end

  def no_special_message
    render :partial => 'no_special_message'
  end

  # Globals
  def check_email
    the_address = params[:user][:email]
    unless the_address.nil?
      the_address.downcase!
    end
    available = User.find_by_email(the_address).blank? ? "true" : "false"
    respond_to do |format|
      format.json { render :json => available }
    end
  end

  def subscription
    redirect_to(logged_in? ? billing_user_path(current_user, :membership => params[:membership]) : sign_up_path(:membership => params[:membership]))
  end

  def ambassador_tools_widget_invite_by_email
    render :template => 'users/ambassador_tools/invite_by_email'
  end

  def ambassador_tools_invite_by_email
    render :template => 'users/ambassador_tools/invite_by_email'
  end

  def ambassador_tools_invite_by_sharing
    render :template => 'users/ambassador_tools/invite_by_sharing'
  end

  def ambassador_tools_preview_email
    @message = params[:message]
    @ambassador = current_user
    render :template => 'users/ambassador_tools/preview_email', :layout => false
  end

  def ambassador_tools_my_invitations
    @ambassador_invites = current_user.ambassador_invites.all
    render :template => 'users/ambassador_tools/my_invitations'
  end

  def ambassador_tools_my_rewards
    render :template => 'users/ambassador_tools/my_rewards'
  end

  def ambassador_tools_help
    render :template => 'users/ambassador_tools/help'
  end

  def redeem_points
    if current_user.redeem_points(params[:redeemed_points].to_i)
      flash[:notice] = "Your points have been redeemed."
      redirect_to billing_history_user_path(current_user)
    else
      flash[:notice] = "An error occurred while trying to redeem your points."
      render :template => 'users/ambassador_tools/my_rewards'
    end
  end

  def select_ambassador
    @show_ambassador_plans = true
    if @ambassador_user
      @billing_cycle = 'Premium Trial'
      cookies[:ambassador_user_id] = @ambassador_user.id.to_s
    else
      flash[:error] = "We could not find a person with an ambassador id of '#{ params[:ambassador_name] }'. Please check that you have typed it correctly."
    end

    case params[:return_to]
      when 'login'
        redirect_to '/sessions/new'
      when 'billing'
        redirect_to billing_user_path(current_user)
      else
        redirect_to sign_up_membership_path(:membership_type => "prepaid")
    end
  end

  def change_ambassador
    @change_ambassador = true
    cookies.delete :ambassador_user_id

    case params[:return_to]
      when 'login'
        redirect_to '/sessions/new'
      when 'billing'
        redirect_to billing_user_path(current_user, :change_ambassador => true)
      else
        @billing_cycle = 'Premium Trial'
        @user = User.new
        setup_fake_values
        render :template => 'users/new'
    end
  end

  def notify_ambassador
    if current_user
      current_user.notify_ambassador_of_reward = params[:value]
      current_user.save
    end
    cookies[:notify_ambassador_of_reward] = params[:value]

    render :update do |page|
    end
  end



  protected

    def authorized?
      logged_in? && current_user == User.find(params[:id])
    end

    def scoper
      current_account.users
    end

    def setup_ambassador
      ambassador_params = { :recipients => params[:recipients], :from => current_user.email }
      ambassador_invite_with_default_body = current_user.ambassador_invite_with_default_body
      ambassador_params[:body] = ambassador_invite_with_default_body.body if ambassador_invite_with_default_body
      @ambassador_invite = AmbassadorInvite.new(ambassador_params)
    end

    def fetch_ambassador
      if params[:ambassador]
        @ambassador_user = User.find_by_ambassador_name(params[:ambassador])
        cookies[:ambassador_user_id] = @ambassador_user.id.to_s if @ambassador_user
      end

      @ambassador_user = current_user.ambassador if current_user
      cookies[:ambassador_user_id] = params[:ambassador_user_id] if @ambassador_user.nil? && params[:ambassador_user_id]
      @ambassador_user = User.find_by_ambassador_name(params[:ambassador_name]) if @ambassador_user.nil? && params[:ambassador_name]
      @ambassador_user = User.find(cookies[:ambassador_user_id]) if @ambassador_user.nil? && cookies[:ambassador_user_id]

      if current_user && @ambassador_user && current_user.id == @ambassador_user.id
        cookies.delete :ambassador_user_id
        @ambassador_user = nil
      end
      logger.debug "DEBUG AmbassadorID=#{ @ambassador_user.id if @ambassador_user } CurrentUser.ambassador_id=#{ current_user.ambassador_id if current_user }"
    end

    def ensure_not_logged_in
      redirect_to profile_user_path(current_user) if logged_in?
    end

    def setup_fake_values
      if Rails.env == 'development'
        @user.name       = Faker::Name.last_name
        @user.first_name = Faker::Name.first_name
        @user.last_name  = Faker::Name.last_name
        @user.email      = @user.email_confirmation = Faker::Internet.email
        @user.password   = @user.password_confirmation = '123456'
        logger.debug "DEBUG User=#{ @user.inspect }"
      end
    end

    def check_gift_card_code
      unless params[:gift_card_code].blank?

        # don't use card service when in dev mode. Instead check against 2 cards
        if Rails.env == 'development'
          if params[:gift_card_code] == '1'
            @gift_card = GiftCardService::GiftCard.new(:serial_number => '1', :balance => '9.95', :expiraton_date => 5.days.since.to_s)
          elsif params[:gift_card_code] == '2'
            @gift_card = GiftCardService::GiftCard.new(:serial_number => '2', :balance => '89.95', :expiraton_date => 5.days.since.to_s)
          end
        else
          soap_endpoint = 'http://yogatodayws.complemar.com/Service1.asmx'
          namespace     = 'http://complemar.com/'
          client        = GiftCardService::API.new(soap_endpoint, namespace)
          @gift_card    = client.search(params[:gift_card_code])
        end

        if @gift_card.nil? || (@gift_card && !@gift_card.valid?)
          flash[:error] = "Your Gift Card Number could not be found"
          
          if @gift_card
            logger.info "Could not validate gift card code: #{@gift_card.inspect}"
          end

          if params[:action] == 'create'
            render :action => 'new'
            return
          else
            redirect_to sign_up_path
          end
        end

        if @gift_card && @gift_card.expired?
          flash[:error] = "Your Gift Card has expired"

          if params[:action] == 'create'
            render :action => 'new'
            return
          else
            redirect_to sign_up_path
          end
        end
      end
    end

    def setup_user
      @user = User.new
      @user.wants_newsletter = true
      @user.wants_promos     = true
      setup_fake_values
    end

    def determine_membership_type
      if %w(monthly prepaid).include?(params[:membership_type].to_s)
        @membership_type = params[:membership_type]
      else
        @membership_type = 'free'
      end

      if @gift_card && @gift_card.valid?
        if @gift_card.balance == 89.95
          @membership_type = 'prepaid'
        else
          @membership_type = 'monthly'
        end
      end
    end

  private

    def apply_ambassador
      result = false
      unless cookies[:ambassador_user_id].blank?
        ambassador = User.find_by_id(cookies[:ambassador_user_id])
        if ambassador
          result = @user.set_ambassador!(ambassador.id, cookies[:notify_ambassador_of_reward])
        end
        cookies.delete :ambassador_user_id
      end
      result
    end

    def valid_billing?
      logger.debug "DEBUG Validating billing_cycle=#{ @billing_cycle } SubscriptionPlan=#{ @subscription_plan }"
      @user.valid? && @creditcard.valid? && @address.valid? && (@billing_cycle || @subscription_plan)
    end

    def setup_ambassador_email
      @ambassador_invite.subject = 'A special invitation to Yoga Today' if @ambassador_invite.subject.nil?
      @ambassador_invite.body = "Hey!\nMaybe you've seen this before, but I've found a great way to practice yoga more often. It's an on-line video studio called Yoga Today, and now they're offering a free 2 week trial. You should look into it and give it a try.\n\nGood luck with your practice!" if @ambassador_invite.body.nil?
    end
end