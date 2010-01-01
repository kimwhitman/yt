class UsersController < ApplicationController
  ssl_required :billing if RAILS_ENV == 'production'

  skip_filter :verify_authenticity_token, :only => [:check_login, :check_email]

  before_filter :login_required,
    :except => [:create, :new, :special_message, :no_special_message, :check_email, :subscription]

  def create
    @user = User.new params[:user]

    unless simple_captcha_valid?
      @user.errors.add_to_base "Captcha is invalid"
    end

    if @user.save

      free_user = params[:membership] && params[:membership] == 'free'

       if free_user
         UserMailer.deliver_welcome(@user)
         self.current_user = nil
       else
         self.current_user = @user
       end

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

  def new
    @user = User.new
    @user.wants_newsletter = true
    @user.wants_promos = true

    if !params[:membership].blank? && %w(free 1 12).include?(params[:membership])
      @billing_cycle = params[:membership]
    else
      @billing_cycle = '1'
    end

    redirect_to profile_user_path(current_user) if logged_in?
  end

  # Member actions
  def billing
    @user = current_user
    @user.attributes = params[:user]

    # @user.add_to_base("You must agree to Membership Terms and Details") unless @user.agree_to_terms?

    @creditcard = ActiveMerchant::Billing::CreditCard.new params[:creditcard]

    begin
      @date = Date.parse("#{@creditcard.month}/#{@creditcard.year}")
    rescue ArgumentError
      @date = Date.parse("Jan #{Date.today.year}")
    end

    if !params[:membership].blank? && params[:membership] == 'free' && request.post?
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
      @billing_cycle = '1'
    end

    if request.post? || request.put?

      @address = SubscriptionAddress.new(:first_name => @creditcard.first_name,
                  :last_name => @creditcard.last_name)

      if valid_billing?
        account_upgrade = !@user.has_paying_subscription?
        @user.account.subscription.upgrade_to_premium(@billing_cycle.to_i)

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
        logger.info "Subscription Error: #{errors}"
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

  protected

    def authorized?
      logged_in? && current_user == User.find(params[:id])
    end

    def scoper
      current_account.users
    end

  private
    def valid_billing?
      @user.valid? && @creditcard.valid? && @address.valid?
    end
end