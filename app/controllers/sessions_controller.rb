# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  skip_before_filter :login_required, :except => :destroy
  skip_before_filter :verify_authenticity_token, :only => :create

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      flash[:notice] = "Logged in successfully"
      # Migrate over the user playlist from session --> DB
      migrate_playlist!
      migrate_cart!
      respond_to do |format|
        format.html { redirect_back_or_default('/') }
        format.js
      end
    else
      flash.now[:error] = 'Invalid login credentials'

      respond_to do |format|
        format.html { render :action => 'new' }
        format.js
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
      render :action => 'forgot_complete'
    else
      flash[:error] = "That account wasn't found."
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
      end
    end
  end
end
