class AmbassadorInvitesController < ApplicationController

  def create
    @ambassador_invite = current_user.ambassador_invites.new(params[:ambassador_invite])
    if @ambassador_invite.save
      case params[:commit]
        when 'Preview'
          # TODO Render template for preview page
          redirect_to 'TODO'
        else
          @ambassador_invite.activate!
          redirect_to ambassador_tools_my_invitations_user_path(current_user)
      end
    else
      render :template => 'users/ambassador_tools/invite_by_email'
    end
  end

end