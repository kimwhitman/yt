class AmbassadorInvitesController < ApplicationController

  def create
    @ambassador_invite = current_user.ambassador_invites.new(params[:ambassador_invite])
    if @ambassador_invite.save
      @ambassador_invite.deliver!
      flash[:success] = "Thanks for sharing Yoga Today. We'll let you know right away when you've earned points for free yoga. <a href=\"#{ ambassador_tools_invite_by_email_user_path(self.current_user) }\">Send another invitation</a>"
      redirect_to ambassador_tools_my_invitations_user_path(current_user)
    else
      render :template => 'users/ambassador_tools/invite_by_email'
    end
  end

end