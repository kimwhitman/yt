class UsersController < ApplicationController
  ssl_required :billing if RAILS_ENV == 'production'
  #include ModelControllerMethods

  #before_filter :check_user_limit, :only => :create
  skip_filter :verify_authenticity_token, :only => [:check_login, :check_email]
  before_filter :login_required,
    :only => [:profile, :membership_terms, :billing, :billing_history, :cancel_membership, :update]
  # CRUD

  def create
    @user = User.new params[:user]

    #params[:email] is a negative captcha technique to catch bots.
    # Humans do not fill out the email field as it is displayed 500 px's to the left,
    # bots see a field called "email" and try to fill it out.
    if params[:email].blank? && @user.save
      self.current_user = @user
      migrate_cart!
      if params[:remember_me] == 1
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      respond_to do |format|
        format.html {
          if params[:membership].blank? || params[:membership] == 'free'
            # EAE this is my way of sending the free subscription welcomes
            SubscriptionNotifier.deliver_plan_changed_free(current_user)
            render :action => 'welcome'
          else
            redirect_to billing_user_url(current_user)
          end
        }
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
        format.html {
          flash[:user_notice] = "<span style='font-size: 14px; color: #488A1A'>Your changes have been saved.</span>"
          redirect_to profile_user_url(current_user)
        }
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
    if logged_in?
      redirect_to profile_user_path(current_user)
    end
  end

  # Member actions
  def billing
    if request.post?
      unless current_user.has_paying_subscription?
        unless params[:agree_to_terms] == "1"
          flash[:notice] = "You must agree to the terms and services to continue."
          render :action => 'billing'
          return
        end
      end

      if params[:creditcard][:number].length > 25
        flash[:notice] = "Your credit card must be less than or equal to 25 characters"
        return
      elsif params[:creditcard][:verification_value].length > 4
        flash[:notice] = "Your verification value must be less than or equal to 4 characters"
        return
      elsif params[:creditcard][:first_name].length > 100
        flash[:notice] = "Your first name must be less than or equal to 100 characters"
        return
      elsif params[:creditcard][:last_name].length > 100
        flash[:notice] = "Your last name must be less than or equal to 100 characters"
        return
      end

      @creditcard = ActiveMerchant::Billing::CreditCard.new params[:creditcard]
      @address = SubscriptionAddress.new params[:address]
      @address.first_name = @creditcard.first_name
      @address.last_name = @creditcard.last_name

      if @creditcard.valid? & @address.valid?
        account_upgrade = !current_user.has_paying_subscription?
        current_user.account.subscription.upgrade_to_premium unless current_user.has_paying_subscription?
        migrate_cart!
        if current_user.account.subscription.store_card(@creditcard, :billing_address => @address.to_activemerchant, :ip => request.remote_ip)
          flash[:notice] = "Your billing information has been updated." unless account_upgrade
          if account_upgrade
            current_user.reload # Out with the old, in with the new.
            @current_account = current_user.account # EAE instance variable was not set to new account
            # EAE was: SubscriptionNotifier.deliver_plan_changed(current_user, current_user.account.subscription)
            SubscriptionNotifier.deliver_plan_changed_upgrade(current_user, current_user.account.subscription)
            render :action => 'subscription_thank_you'
          else
            redirect_to billing_user_url(current_user)
          end
        else
          flash[:error_messages] = current_user.account.subscription.errors.full_messages.join('<br />')
          current_user.account.subscription.reload
        end
      else
        flash[:error_messages] = (@creditcard.errors.full_messages + @address.errors.full_messages + current_account.subscription.errors.full_messages).join('<br />')
        render :action => 'billing'
      end
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
    # EAE was: SubscriptionNotifier.deliver_plan_changed(current_user, sub)
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

    def check_user_limit
      redirect_to new_user_url if current_account.reached_user_limit?
    end
end
