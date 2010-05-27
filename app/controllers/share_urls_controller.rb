class ShareUrlsController < ApplicationController
  before_filter :fetch_share_url

  def show
    if request.env['X_HTTP_REFERER'].blank?
      http_referer = request.env['HTTP_REFERER']
    else
      http_referer = request.env['X_HTTP_REFERER']
    end
    RAILS_DEFAULT_LOGGER.warn("DEBUG: #{request.env.inspect}")

    if @share_url
      @share_url.track_redirect({ :referrer => http_referer, :remote_ip => request.remote_ip,
      :domain => http_referer}.merge(logged_in? ? {:user => current_user} : {}))

      if @share_url.destination
        # Redirect to destination
        redirect_to @share_url.destination
      else
        # Redirect to Ambassador URL
        redirect_to "/get-started-today?ambassador=#{@share_url.user.ambassador_name}"
      end
    else

    end
  end

  protected
    def fetch_share_url
      @share_url = ShareUrl.find_by_token(params[:id])
      redirect_to '/' if @share_url.nil?
    end
end