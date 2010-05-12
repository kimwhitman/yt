class AmbassadorInvitesController < ApplicationController

  def create
    @ambassador_invite = current_user.ambassador_invites.new(params[:ambassador_invite])
    if @ambassador_invite.save
      @ambassador_invite.deliver!
      redirect_to ambassador_tools_my_invitations_user_path(current_user)
    else
      render :template => 'users/ambassador_tools/invite_by_email'
    end
  end

end