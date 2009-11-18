class ConfirmationsController < ApplicationController
  filter_parameter_logging :token

  def new
    create
  end

  def create
    @user = User.find_by_id_and_confirmation_token(
                   params[:user_id], params[:token])
    @user.confirm_email!

    self.current_user = @user

    flash_success_after_create
    redirect_to(root_url)
  end

  private

  def flash_success_after_create
    flash[:success] = "Confirmed email and signed in."
  end
end