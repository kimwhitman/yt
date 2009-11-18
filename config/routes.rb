ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "pages", :action => "home"
  map.admin_root '/admin', :controller => 'admin/base', :action => 'index'
  # See how all your routes lay out with "rake routes"
  map.plans '/signup', :controller => 'accounts', :action => 'plans'
  map.thanks '/signup/thanks', :controller => 'accounts', :action => 'thanks'
  map.resource :account, :collection => { :dashboard => :get, :thanks => :get, :plans => :get, :billing => :any, :paypal => :any, :plan => :any, :cancel => :any, :canceled => :get }
  map.new_account '/signup/:plan', :controller => 'accounts', :action => 'new', :plan => nil

  map.login  '/login',  :controller => 'Sessions', :action => 'new'
  map.logout '/logout', :controller => 'Sessions', :action => 'destroy'

  map.resources :users,
    :collection => { :check_email => :post },
    :member => { :profile => :any, :billing => :any,
      :billing_history => :get, :membership_terms => :get, :cancel_membership => :any
    }
  map.resource :session
  map.resources :videos, :collection => { :search => :any }, :member => { :leave_suggestion => :post } do |videos|
    videos.resources :comments
    videos.resources :reviews
  end
  map.resources :user_stories
  map.forgot_password '/forgot-password', :controller => 'sessions', :action => 'forgot'
  map.reset_password '/reset-password/:token', :controller => 'sessions', :action => 'reset'
  # admin-level stuff

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
      'promotions-and-events', 'terms-and-conditions', 'get-started-today']
    root_pages.each do |root_page|
      eval "pages.#{root_page.underscore} '/#{root_page}', :action => root_page.underscore"
    end
  end
  # Da blog redirector
  #map.connect '*blog', :controller => 'blog', :action => 'index'
  # Purchase-related stuff.
  map.cart '/cart', :controller => 'shopping_cart', :action => 'show'
  map.playlist '/playlist', :controller => 'playlists', :action => 'show'
  map.checkout '/checkout', :controller => 'shopping_cart', :action => 'checkout'
  map.confirm_purchase '/confirm-purchase', :controller => 'shopping_cart', :action => 'confirm_purchase'
  map.purchase '/purchase/:id', :controller => 'purchases', :action => 'show'
  map.purchase_item '/purchase/:invoice_no/download/:id', :controller => 'purchases', :action => 'download'
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
