class UsersController < ApplicationController
  ssl_required :billing if RAILS_ENV == 'production'

  skip_filter :verify_authenticity_token, :only => [:check_login, :check_email]

  before_filter :login_required,
    :except => [:create, :new, :special_message, :no_special_message, :check_email]

  def create
    @user = User.new params[:user]

    if @user.save
      SubscriptionNotifier.deliver_email_confirmation(@user)

      self.current_user = @user
      migrate_cart!

      if params[:remember_me] == 1
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end

      respond_to do |format|
        format.html do
          if params[:membership].blank? || params[:membership] == 'free'
            self.current_user = nil
            # EAE this is my way of sending the free subscription welcomes
            SubscriptionNotifier.deliver_plan_changed_free(@user)
            render :action => 'welcome'
          else
            redirect_to billing_user_url(current_user)
          end
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

    redirect_to profile_user_path(current_user) if logged_in?
  end

  # Member actions
  def billing
    @user = current_user
    @user.attributes = params[:user]

    @creditcard = ActiveMerchant::Billing::CreditCard.new params[:creditcard]

    if !params[:billing_cycle].blank?
      @billing_cycle = params[:billing_cycle]
    elsif @user.has_paying_subscription?
      @billing_cycle = @user.account.subscription.renewal_period.to_s
    else
      @billing_cycle = '1'
    end

    begin
      @date = Date.parse("#{@creditcard.month}/#{@creditcard.year}")
    rescue ArgumentError
      @date = Date.parse("Jan #{Date.today.year}")
    end

    if request.post? || request.put?

      @address = SubscriptionAddress.new(:first_name => @creditcard.first_name,
                  :last_name => @creditcard.last_name)

      if valid_billing?
        account_upgrade = !@user.has_paying_subscription?
        @user.account.subscription.upgrade_to_premium(@billing_cycle.to_i)

        migrate_cart!

        if @user.account.subscription.store_card(@creditcard, :billing_address => @address.to_activemerchant, :ip => request.remote_ip)
          flash[:notice] = "Your billing information has been updated."# unless account_upgrade

          if account_upgrade
            @user.reload # Out with the old, in with the new.
            @current_account = @user.account # EAE instance variable was not set to new account
            SubscriptionNotifier.deliver_plan_changed_upgrade(@user, @user.account.subscription)
            render :action => 'subscription_thank_you'
          else
            redirect_to billing_user_url(@user)
          end

        else
          errors = @user.account.subscription.errors.full_messages
          logger.info "Subscription Error: #{errors}"
          flash[:error_messages] = errors.join("<br/>")
          @user.account.subscription.reload
        end

      else
        errors = @creditcard.errors.full_messages + @address.errors.full_messages + current_account.subscription.errors.full_messages
        logger.info "Subscription Error: #{errors}"
        flash[:error_messages] = errors.join("<br/>")
        render :action => 'billing'
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
    sub = Subscription.find(current_user.account.subscription.id)
    sub.downgrade_to_free
    current_user.cart_items_to_non_subscription_price
    sub.destroy_gateway_record!
    sub.save!
    SubscriptionNotifier.deliver_plan_changed_cancelled(current_user, sub)
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
