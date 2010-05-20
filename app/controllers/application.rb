# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include SslRequirement
  #include ExceptionNotifiable
  #before_filter :login_required

  helper :all # include all helpers, all the time
  helper_method :current_account, :admin?, :shopping_cart, :current_purchase, :user_playlist, :free_video_of_week, :featured_video_of_week

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '779a6e2f0fe7736f0a73da4a7d9f13d4'

  filter_parameter_logging :password, :creditcard

  before_filter :check_for_ambassador
  before_filter :remove_invalid_ambassador_cookie

  def signed_in?
    ! current_user.nil?
  end


  protected

    def current_account
      @current_account ||= current_user.account
    end

    def admin?
      logged_in? && current_user.admin?
    end

    def shopping_cart
      @cart ||= if session[:cart_id]
        Cart.find(session[:cart_id])
      elsif logged_in?
        Cart.find_or_create_by_user_id(current_user.id)
      else
        Cart.create!
      end
      session[:cart_id] = @cart.id
      @cart
    end

    def empty_cart!
      shopping_cart.cart_items.delete_all
      session[:cart_id] = nil
    end

    def current_purchase
      session[:purchase_record] ||= Purchase.new
    end

    def last_purchase
      @last_purchase ||= Purchase.find(session[:last_purchase_id])
    end

    def free_video_of_week
      @free_video_of_week ||= FeaturedVideo.free_videos.first
    end

    def featured_video_of_week
      @featured_video_of_week ||= FeaturedVideo.find(:first)
    end

    def user_playlist(from_session = false)
      if logged_in? && !from_session
        current_user.playlist
      else
        session[:temp_playlist] ||= UserPlaylist.new
      end
    end

    def migrate_playlist!
      UserPlaylist.migrate_to_user(current_user, user_playlist(true))
      session[:temp_playlist] = nil
    end

    def migrate_cart!
      current_user.reload
      shopping_cart.user = current_user
      shopping_cart.save
    end

    def destroy_current_purchase!
      session[:last_purchase_id] = current_purchase.id
      session[:purchase_record] = nil
    end

    def rescue_action(ex)
      if ex.is_a?(CGI::Session::CookieStore::TamperedWithCookie)
        Rails.logger.info "Bad cookie; resetting session"
        session.reset!
        redirect_to '/'
      else
        super(ex)
      end
    end

    def check_for_ambassador
      if params.keys.include?('ambassador') && cookies[:ambassador_user_id].nil?
        ambassador = User.find_by_ambassador_name(params[:ambassador])
        if ambassador
          cookies[:ambassador_user_id] = ambassador.id.to_s unless ambassador.nil?
          redirect_to request.request_uri
        end
      end
    end

    # This works around some fucked-up weird problem that only happens
    # in development mode.
    # When you reference 'User' in AuthenticatedSystem
    # It won't let get unloaded from memory, and generates errors up the ass.
    def user_class
      User
    end

    def remove_invalid_ambassador_cookie
      if current_user && current_user.ambassador_name
        cookies.delete :ambassador_user_id if current_user.id == cookies[:ambassador_user_id]
      end
    end
end
