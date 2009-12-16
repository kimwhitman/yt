class ConfirmationsController < ApplicationController
  filter_parameter_logging :token

  before_filter :forbid_missing_token,     :only => [:new, :create]
  before_filter :forbid_non_existent_user, :only => [:new, :create]

  def new
    create
  end

  def create
    @user = User.find_by_id_and_confirmation_token(
                   params[:user_id], params[:token])

    @user.confirm_email!

    self.current_user = @user

    SubscriptionNotifier.deliver_welcome(@user)

    flash_success_after_create

    redirect_to billing_user_url(current_user)
  end

  private

  def forbid_missing_token
    if params[:token].blank?
      raise ActionController::UnknownAction, "missing token"
    end
  end

  def forbid_non_existent_user
    unless ::User.find_by_id_and_confirmation_token(
                  params[:user_id], params[:token])
      raise ActionController::UnknownAction, "non-existent user"
    end
  end

  def flash_success_after_create
    flash[:success] = "Confirmed email and signed in."
  end
end
