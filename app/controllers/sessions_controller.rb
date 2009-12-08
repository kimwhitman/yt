# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  skip_before_filter :login_required, :except => :destroy
  skip_before_filter :verify_authenticity_token, :only => :create

  def create
    @user = User.authenticate(params[:session][:email], params[:session][:password])

    if @user.nil?

      respond_to do |format|
        format.html do
          flash[:error] = "Could not authenticate your account"
          render :action => 'new', :status => :unauthorized
        end
        format.js do
          flash_failure_after_create
          render :text => "Could not authenticate your account", :status => :unauthorized
        end
      end
    else
      if @user.email_confirmed?
        self.current_user = @user

        if params[:remember_me] == "1"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end

        # Migrate over the user playlist from session --> DB
        migrate_playlist!
        migrate_cart!

        respond_to do |format|
          format.html { flash_success_after_create; redirect_back_or_default(root_url) }
          format.js   { render :text => "Authorized", :status => :ok }
        end
      else

        respond_to do |format|
          format.html { flash_notice_after_create; redirect_to(new_session_url) }
          format.js   { render :text => "Please confirm your email addres", :status => :unauthorized }
        end
      end
    end

  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  def forgot
    return unless request.post?

    if !params[:email].blank? && @user = User.find_by_email(params[:email])
      PasswordReset.create(:user => @user, :remote_ip => request.remote_ip)

      respond_to do |format|
        format.html { render :action => 'forgot_complete' }
        format.js   { render :text => "An email to reset your password has been sent", :status => :ok }
      end
    else
      error = "That account wasn't found."
      respond_to do |format|
        format.html { flash[:error] = error }
        format.js   { render :text => error, :status => :not_found }
      end

    end
  end

  def reset
    @password_reset = PasswordReset.find_by_token(params[:token])
    if @password_reset.blank? || 1.week.ago > @password_reset.created_at
      render :action => 'invalid_reset_token'
      return
    end
    @user = @password_reset.user
    return unless request.post?

    if !params[:user][:password].blank? &&
      if @user.update_attributes(:password => params[:user][:password],
        :password_confirmation => params[:user][:password_confirmation])
        @password_reset.destroy
        flash[:notice] = "Your password has been updated.  Please log in with your new password."
        render :action => 'successful_reset'
      else
        self.current_user = nil
        flash[:error] = 'Your password was not reset. Please try the email link again and provide a new password'
        render :action => 'failed_reset'
      end
    end
  end


  private

  def flash_failure_after_create
    flash.now[:failure] = "Bad email or password"
  end

  def flash_success_after_create
    flash[:success] = "Signed in."
  end

  def flash_notice_after_create
    flash[:notice] = "User has not confirmed email"
  end
end
