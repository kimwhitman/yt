class ShareUrlsController < ApplicationController
  before_filter :fetch_share_url
  
  def show
    if @share_url
      @share_url.track_redirect({ :referrer => request.env['HTTP_REFERER'], :remote_ip => request.remote_ip, 
      :domain => request.env['HTTP_REFERER']}.merge(logged_in? ? {:user => current_user} : {}))
      
      if @share_url.destination
        # Redirect to destination
        redirect_to @share_url.destination
      else
        # Redirect to Ambassador URL
        # TODO: Ambassador URL goes here
      end
    else
      
    end
  end
  
  protected
    def fetch_share_url
      @share_url = ShareUrl.find_by_token(params[:id])
    end
end