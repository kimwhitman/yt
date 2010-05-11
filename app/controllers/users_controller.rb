class UsersController < ApplicationController
  ssl_required :billing if RAILS_ENV == 'production'

  skip_filter :verify_authenticity_token, :only => [:check_login, :check_email]
  before_filter :login_required,
    :except => [:create, :new, :special_message, :no_special_message, :check_email, :subscription, :select_ambassador,
      :change_ambassador]
  before_filter :setup_ambassador, :only => [:ambassador_tools_invite_by_email, :ambassador_tools_widget_invite_by_email]
  before_filter :fetch_ambassador, :only => [:new, :create, :select_ambassador, :billing]


  def new
    @user = User.new
    @user.wants_newsletter = true
    @user.wants_promos = true
    setup_fake_values

    if !params[:membership].blank? && %w(free 1 12).include?(params[:membership])
      @billing_cycle = params[:membership]
    else
      @billing_cycle = '1'
    end

    redirect_to profile_user_path(current_user) if logged_in?
  end

  def create
    @user = User.new params[:user]

    @user.valid?

    if @user.errors.count == 0 && @user.save
      free_user = params[:membership] && params[:membership] == 'free'

      UserMailer.deliver_welcome(@user) if free_user
      self.current_user = @user

      respond_to do |format|
        format.html do
          if free_user
            render :action => "welcome"
          else
            redirect_to billing_user_url(@user, :membership => params[:membership])
          end
          return
         end
        format.js
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.js
      end
    end
  end

  def update
    if params[:user][:password] == ";9p=4-32"
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    current_user.attributes = params[:user]

    if current_user.save
      respond_to do |format|
        format.html do
          flash[:user_notice] = "<span style='font-size: 14px; color: #488A1A'>Your changes have been saved.</span>"
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
      @creditcard.number = '1'
      @creditcard.verification_value = '123'
      #@creditcard.year = Time.now.year + 1
      @creditcard.first_name = 'John'
      @creditcard.last_name = 'Smith'
      @user.agree_to_terms = 1
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
      @billing_cycle = @user.account.subscription.renewal_period.to_s
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
          @user.account.subscription.reload
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
    @subscription.downgrade_to_free
    current_user.cart_items_to_non_subscription_price
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

  def ambassador_tools_my_invitations
    @ambassador_invites = current_user.ambassador_invites.find(:all, :conditions => ["state = ?", 'active'])
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
      redirect_to billing_user_path(current_user)
    else
      flash[:notice] = "An error occurred while trying to redeem your points."
      render :template => 'users/ambassador_tools/my_rewards'
    end
  end

  def select_ambassador
    if @ambassador_user
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
        @user = User.new
        setup_fake_values
        render :template => 'users/new'
    end
  end

  def change_ambassador
    @change_ambassador = true
    cookies.delete :ambassador_user_id

    case params[:return_to]
      when 'login'
        redirect_to '/sessions/new'
      when 'billing'
        redirect_to billing_user_path(current_user)
      else
        @user = User.new
        setup_fake_values
        render :template => 'users/new'
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
      @ambassador_user = current_user.ambassador if current_user
      @ambassador_user = User.find_by_ambassador_name(params[:ambassador_name]) if @ambassador_user.nil? && params[:ambassador_name]
      @ambassador_user = User.find(cookies[:ambassador_user_id]) if @ambassador_user.nil? && cookies[:ambassador_user_id]
    end

    def setup_fake_values
      if Rails.env == 'development'
        @user.name = Faker::Name.last_name
        @user.email = @user.email_confirmation = Faker::Internet.email
        @user.password = @user.password_confirmation = Faker::Name.first_name << Faker::Name.last_name
        logger.debug "DEBUG User=#{ @user.inspect }"
      end
    end



  private

    def valid_billing?
      logger.debug "DEBUG: Validating billing_cycle=#{ @billing_cycle } SubscriptionPlan=#{ @subscription_plan }"
      @user.valid? && @creditcard.valid? && @address.valid? && (@billing_cycle || @subscription_plan)
    end
end