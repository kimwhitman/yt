ActionController::Routing::Routes.draw do |map|

  map.resource :account,
    :collection => {
      :billing   => :any,
      :cancel    => :any,
      :canceled  => :get,
      :dashboard => :get,
      :paypal    => :any,
      :plan      => :any,
      :plans     => :get,
      :thanks    => :get,
    }

  map.login  '/login',  :controller => 'Sessions', :action => 'new'
  map.logout '/logout', :controller => 'Sessions', :action => 'destroy'

  map.resources :ambassador_invites

  map.resources :users,
    :collection => {
      :change_ambassador => :post,
      :check_email => :post,
      :notify_ambassador => :post,
      :select_ambassador => :any,
      :subscription => :get,
    },
    :member => {
      :ambassador_tools_help                   => :get,
      :ambassador_tools_invite_by_email        => :get,
      :ambassador_tools_invite_by_sharing      => :get,
      :ambassador_tools_my_invitations         => :get,
      :ambassador_tools_my_rewards             => :get,
      :ambassador_tools_preview_email          => :get,
      :ambassador_tools_widget_invite_by_email => :post,
      :billing                                 => :any,
      :billing_history                         => :get,
      :cancel_membership                       => :any,
      :membership_terms                        => :get,
      :profile                                 => :any,
      :redeem_points                           => :post,
      :select_ambassador_name                  => :put,
      :signup                                  => :get,
      }

  map.resources :users do |users|
    users.resource :confirmation, :only => [:new, :create]
  end

  map.resource :session

  map.resources :videos,
    :collection => {
      :brightcove_test       => :get,
      :lineup                => :get,
      :search                => :any,
      :this_weeks_free_video => :get,
    },
    :member => { :leave_suggestion => :post } do |videos|
      videos.resources :comments
      videos.resources :reviews
    end

  map.resources :user_stories

  map.forgot_password '/forgot-password',       :controller => 'sessions', :action => 'forgot'
  map.reset_password  '/reset-password/:token', :controller => 'sessions', :action => 'reset'

  # ADMIN
  map.admin_root '/admin', :controller => 'admin/base', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :site_searches,
      :collection => {
        :search               => :get,
        :select_search_result => :get,
        :view_results         => :any,
      }
    admin.resources :billing_transactions
    admin.resources :users,
      :member => { :cancel_subscription => :post }
  end
  map.admin_ambassador_referrals '/admin/analytics/ambassador_referrals', :controller => 'admin/analytics',
    :action => 'ambassador_referrals'


  # Root-level routes.
  map.with_options :controller => 'sessions' do |sessions|
    sessions.sign_out '/sign-out', :action => 'destroy'
    sessions.connect '/sign-in',   :action => 'create'

    sessions.sign_in '/sign-in',   :action => 'create',
      :conditions => { :method => :post }

    sessions.sign_in '/sign-in',
      :action => 'new',
      :conditions => { :method => :get }

    sessions.formatted_sign_in '/sign-in.:format',
      :action => 'create',
      :conditions => { :method => :post }
  end

  map.with_options :controller => 'users' do |users|
    users.sign_up_membership '/sign-up/:membership_type', :action => 'new'
    users.sign_up            '/sign-up/',                 :action => 'signup'
  end

  # Routes for Pages
  map.resources :pages, :collection => { :ask_question => :post }

  map.with_options :controller => 'pages' do |pages|
    [
      'about',
      'advertising',
      'ambassador-details',
      'ambassador-terms-and-conditions',
      'contact',
      'faqs',
      'get-started-today',
      'home',
      'instructors',
      'media-downloads',
      'news',
      'press-and-news',
      'privacy-policy',
      'promotions-and-events',
      'terms-and-conditions',
    ].each do |root_page|
      eval "pages.#{root_page.underscore} '/#{root_page}', :action => root_page.underscore"
    end
  end

  # Purchase-related stuff
  map.cart             '/cart',             :controller => 'shopping_cart', :action => 'show'
  map.checkout         '/checkout',         :controller => 'shopping_cart', :action => 'checkout'
  map.confirm_purchase '/confirm-purchase', :controller => 'shopping_cart', :action => 'confirm_purchase'
  map.playlist         '/playlist',         :controller => 'playlists',     :action => 'show'
  map.purchase         '/purchase/:id',     :controller => 'purchases',     :action => 'show'

  map.purchase_item '/purchase/:invoice_no/download/:id', :controller => 'purchases',   :action => 'download'
  map.master_feed   '/master_feed.:format',               :controller => 'master_feed', :action => 'index'

  map.root :controller => "pages", :action => "home"

  # This has to be the last route before the defaults
  map.share_url '/sr/:id', :controller => 'share_urls', :action => 'show'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
