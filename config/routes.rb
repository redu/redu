ActionController::Routing::Routes.draw do |map|
  map.resources :profiles

  map.resources :abilities

  map.resources :resources, :collection => { :search => [:get, :post], :add => :get, :favorites => :get }, :member => {:rate => :post}

  map.resources :competences

  map.resources :questions, :collection => { :search => [:get, :post], :add => :get } #, :member => {:add => :get}
  
  map.resources :exams, :member => {:add_question => :get, :add_resource => :get, :rate => :post},
                        :collection => {:unpublished => :get, :new_exam => :get, :discard_draft => :get, :exam_history => :get, :sort => :get, :order => :get, :favorites => :get}
    
  map.resources :subjects

  map.resources :courses, :member => {:rate => :post, :buy => :get},  :collection => {:pending => :get, :favorites => :get}
  
  map.resources :user_school_association

  map.resources :credits
    
  map.resources :schools 
  
  map.resources :annotations
  
  #map.resources :favorites, 

  map.connect 'activity_xml.xml', :controller => "users", :action => "activity_xml", :format => 'xml'
  
  
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
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end
  
  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  
  # See how all your routes lay out with "rake routes"
  
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.

=begin
  map.resources :schools, :member_path => '/:id', :nested_member_path => '/:school_id', :member => { 
      :students => :get
  } do |school|
    #school.resources :students :subjects
  end
=end

  # Add this after any of your own existing routes, but before the default rails routes:
  #map.routes_from_plugin :community_engine
  #Forum routes go first
  map.recent_forum_posts '/forums/recent', :controller => 'sb_posts', :action => 'index'
  map.resources :forums, :sb_posts, :monitorship
  map.resources :sb_posts, :name_prefix => 'all_', :collection => { :search => :get, :monitored => :get }
  
%w(forum).each do |attr|
    map.resources :sb_posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id"
  end
  
  map.resources :forums do |forum|
    forum.resources :moderators
    forum.resources :topics do |topic|
      topic.resources :sb_posts
      topic.resource :monitorship, :controller => :monitorships
    end
  end
  map.forum_home '/forums', :controller => 'forums', :action => 'index'
  map.resources :topics
  
  map.connect 'sitemap.xml', :controller => "sitemap", :action => "index", :format => 'xml'
  map.connect 'sitemap', :controller => "sitemap", :action => "index"
  
  if AppConfig.closed_beta_mode
    map.connect '', :controller => "base", :action => "teaser"
    map.home 'home', :controller => "base", :action => "site_index"
  else
    map.home '', :controller => "base", :action => "site_index"
  end
  map.application '', :controller => "base", :action => "site_index"
  
  # Pages
  map.resources :pages, :path_prefix => '/admin', :name_prefix => 'admin_', :except => :show, :member => { :preview => :get }
  map.pages "pages/:id", :controller => 'pages', :action => 'show'
  
  # admin routes
  
  map.admin_dashboard   '/admin/dashboard', :controller => 'homepage_features', :action => 'index'
  map.admin_users       '/admin/users', :controller => 'admin', :action => 'users'
  map.admin_messages    '/admin/messages', :controller => 'admin', :action => 'messages'
  map.admin_comments    '/admin/comments', :controller => 'admin', :action => 'comments'
  map.admin_tags        'admin/tags/:action', :controller => 'tags', :defaults => {:action=>:manage}
  map.admin_events      'admin/events', :controller => 'admin', :action=>'events'
  
  # sessions routes
  map.teaser '', :controller=>'base', :action=>'teaser'
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup_by_id '/signup/:inviter_id/:inviter_code', :controller => 'users', :action => 'new'
  
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.forgot_username '/forgot_username', :controller => 'users', :action => 'forgot_username'  
  map.resend_activation '/resend_activation', :controller => 'users', :action => 'resend_activation' 
  
  
  #clippings routes
  map.connect '/new_clipping', :controller => 'clippings', :action => 'new_clipping'
  map.site_clippings '/clippings', :controller => 'clippings', :action => 'site_index'
  map.rss_site_clippings '/clippings.rss', :controller => 'clippings', :action => 'site_index', :format => 'rss'
  
  map.featured '/featured', :controller => 'posts', :action => 'featured'
  map.featured_rss '/featured.rss', :controller => 'posts', :action => 'featured', :format => 'rss'
  map.popular '/popular', :controller => 'posts', :action => 'popular'
  map.popular_rss '/popular.rss', :controller => 'posts', :action => 'popular', :format => 'rss'
  map.recent '/recent', :controller => 'posts', :action => 'recent'
  map.recent_rss '/recent.rss', :controller => 'posts', :action => 'recent', :format => 'rss'
  map.rss_redirect '/rss', :controller => 'base', :action => 'rss_site_index'
  map.rss '/site_index.rss', :controller => 'base', :action => 'site_index', :format => 'rss'
  
  map.advertise '/advertise', :controller => 'base', :action => 'advertise'
  map.css_help '/css_help', :controller => 'base', :action => 'css_help'  
  map.about '/about', :controller => 'base', :action => 'about'
  map.faq '/faq', :controller => 'base', :action => 'faq'
  
  
  map.edit_account_from_email '/account/edit', :controller => 'users', :action => 'edit_account'
  
  map.friendships_xml '/friendships.xml', :controller => 'friendships', :action => 'index', :format => 'xml'
  map.friendships '/friendships', :controller => 'friendships', :action => 'index'
  
  map.manage_photos 'manage_photos', :controller => 'photos', :action => 'manage_photos'
  map.create_photo 'create_photo.js', :controller => 'photos', :action => 'create', :format => 'js'
  
  map.resources :sessions
  map.resources :statistics, :collection => {:activities => :get, :activities_chart => :get}
  map.resources :tags, :member_path => '/tags/:id'
  map.show_tag_type '/tags/:id/:type', :controller => 'tags', :action => 'show'
  map.search_tags '/search/tags', :controller => 'tags', :action => 'show'
  
  map.resources :categories
  map.resources :skills, :collection => { :sub_categories_of => :get } 
  map.resources :events, :collection => { :past => :get, :ical => :get } do |event|
    event.resources :rsvps, :except => [:index, :show]
  end
  map.resources :favorites, :path_prefix => '/:favoritable_type/:favoritable_id'
  map.resources :comments, :path_prefix => '/:commentable_type/:commentable_id'
  map.delete_selected_comments 'comments/delete_selected', :controller => "comments", :action => 'delete_selected'
  
  map.resources :homepage_features
  map.resources :metro_areas
  map.resources :ads
  map.resources :contests, :collection => { :current => :get }
  map.resources :activities, :collection => { :recent => :get }
  
  map.resources :users, :member_path => '/:id', :nested_member_path => '/:user_id', :member => { 
    :followers => :get,
    :follows => :get,
    :follow => :get,
    :unfollow => :get,
    :dashboard => :get,
    :assume => :get,
    :toggle_moderator => :put,
    :toggle_featured => :put,
    :change_profile_photo => :put,
    :return_admin => :get, 
    :edit_account => :get,
    :update_account => :put,
    :edit_pro_details => :get,
    :update_pro_details => :put,      
    :forgot_password => [:get, :post],
    :signup_completed => :get,
    :invite => :get,
    :welcome_photo => :get, 
    :welcome_about => :get, 
    :welcome_stylesheet => :get, 
    :welcome_invite => :get,
    :welcome_complete => :get,
    :statistics => :any,
    :activity_xml => :get,
    :deactivate => :put,
    :crop_profile_photo => [:get, :put],
    :upload_profile_photo => [:get, :put]
  } do |user|
    user.resources :friendships, :member => { :accept => :put, :deny => :put }, :collection => { :accepted => :get, :pending => :get, :denied => :get }
    user.resources :photos, :collection => {:swfupload => :post, :slideshow => :get}
    user.resources :posts, :collection => {:manage => :get}, :member => {:contest => :get, :send_to_friend => :any, :update_views => :any}
    user.resources :events # Needed this to make comments work
    user.resources :clippings
    user.resources :activities, :collection => {:network => :get}
    user.resources :invitations
    user.resources :resources, :collection => {:published => :get, :unpublished => :get, :history => :get, :favorites => :get} 
    user.resources :courses, :collection => {:published => :get, :unpublished => :get, :waiting => :get, :favorites => :get} 
    user.resources :schools, :collection => {:member => :get, :owner => :get}
    user.resources :exams, :collection => {:published => :get, :unpublished => :get, :history => :get, :favorites => :get} 
    user.resources :questions
    user.resources :credits
    user.resources :offerings, :collection => {:replace => :put}
    user.resources :favorites,:collection => {:courses => :get} 
    user.resources :messages, :collection => { :delete_selected => :post, :auto_complete_for_username => :any }  
    user.resources :comments
    user.resources :photo_manager, :only => ['index']
    user.resources :albums, :path_prefix => ':user_id/photo_manager', :member => {:add_photos => :get, :photos_added => :post}, :collection => {:paginate_photos => :get}  do |album| 
      album.resources :photos, :collection => {:swfupload => :post, :slideshow => :get}
    end
  end
  map.resources :votes
  map.resources :invitations
  
  map.users_posts_in_category '/users/:user_id/posts/category/:category_name', :controller => 'posts', :action => 'index', :category_name => :category_name
  
  map.with_options(:controller => 'theme', :filename => /.*/, :conditions => {:method => :get}) do |theme|
    theme.connect 'stylesheets/theme/:filename', :action => 'stylesheets'
    theme.connect 'javascripts/theme/:filename', :action => 'javascript'
    theme.connect 'images/theme/:filename',      :action => 'images'
  end
  
  # Deprecated routes
  map.deprecated_popular_rss '/popular_rss', :controller => 'base', :action => 'popular', :format => 'rss'    
  map.deprecated_category_rss '/categories/:id;rss', :controller => 'categories', :action => 'show', :format => 'rss'  
  map.deprecated_posts_rss '/:user_id/posts;rss', :controller => 'posts', :action => 'index', :format => 'rss'
  
  
  
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'     
  
end
