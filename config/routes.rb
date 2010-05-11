ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  map.root :controller => "pages", :action => "home"
  map.plans '/signup', :controller => 'accounts', :action => 'plans'
  map.thanks '/signup/thanks', :controller => 'accounts', :action => 'thanks'
  map.resource :account, :collection => { :dashboard => :get, :thanks => :get, :plans => :get, :billing => :any, :paypal => :any, :plan => :any, :cancel => :any, :canceled => :get }
  map.new_account '/signup/:plan', :controller => 'accounts', :action => 'new', :plan => nil
  map.login  '/login',  :controller => 'Sessions', :action => 'new'
  map.logout '/logout', :controller => 'Sessions', :action => 'destroy'

  map.resources :ambassador_invites
  map.resources :users,
    :collection => { :check_email => :post, :subscription => :get, :select_ambassador => :any, :change_ambassador => :post },
    :member => { :profile => :any, :billing => :any, :billing_history => :get, :membership_terms => :get,
      :cancel_membership => :any, :ambassador_tools_invite_by_email => :get, :ambassador_tools_invite_by_sharing => :get,
      :ambassador_tools_my_invitations => :get, :ambassador_tools_my_rewards => :get, :ambassador_tools_help => :get,
      :ambassador_tools_widget_invite_by_email => :post, :redeem_points => :post }

  map.resources :users do |users|
    users.resource :confirmation, :only => [:new, :create]
  end

  map.resource :session
  map.resources :videos, :collection => { :search => :any, :this_weeks_free_video => :get, :lineup => :get },
    :member => { :leave_suggestion => :post } do |videos|
    videos.resources :comments
    videos.resources :reviews
  end

  map.resources :user_stories
  map.forgot_password '/forgot-password', :controller => 'sessions', :action => 'forgot'
  map.reset_password '/reset-password/:token', :controller => 'sessions', :action => 'reset'

  # admin-level stuff
  map.admin_root '/admin', :controller => 'admin/base', :action => 'index'

  # Root-level routes.
  map.with_options :controller => 'sessions' do |sessions|
    sessions.sign_out '/sign-out', :action => 'destroy'
    sessions.connect '/sign-in', :action => 'create'
    sessions.sign_in '/sign-in', :action => 'create',
      :conditions => { :method => :post }
    sessions.sign_in '/sign-in', :action => 'new',
      :conditions => { :method => :get }
    sessions.formatted_sign_in '/sign-in.:format', :action => 'create',
      :conditions => { :method => :post }
  end

  map.with_options :controller => 'users' do |users|
    users.sign_up '/sign-up', :action => 'new'
  end

  # Routes for Pages
  map.with_options :controller => 'pages' do |pages|
    root_pages = ['about', 'advertising', 'contact', 'faqs', 'home',
      'instructors', 'news',
      'media-downloads', 'press-and-news', 'privacy-policy',
      'promotions-and-events', 'terms-and-conditions', 'get-started-today', 'ambassador-details']
    root_pages.each do |root_page|
      eval "pages.#{root_page.underscore} '/#{root_page}', :action => root_page.underscore"
    end
  end

  # Purchase-related stuff.
  map.cart '/cart', :controller => 'shopping_cart', :action => 'show'
  map.playlist '/playlist', :controller => 'playlists', :action => 'show'
  map.checkout '/checkout', :controller => 'shopping_cart', :action => 'checkout'
  map.confirm_purchase '/confirm-purchase', :controller => 'shopping_cart', :action => 'confirm_purchase'
  map.purchase '/purchase/:id', :controller => 'purchases', :action => 'show'
  map.purchase_item '/purchase/:invoice_no/download/:id', :controller => 'purchases', :action => 'download'

  # This has to be the last route before the defaults
  map.share_url '/sr/:id', :controller => 'share_urls', :action => 'show'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
