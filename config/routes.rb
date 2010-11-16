ActionController::Routing::Routes.draw do |map|
  map.connect 'clipboard/:action/:folder_or_file/:id',
    :controller => 'clipboard',
    :requirements => { :action         => /(add|remove)/,
                       :folder_or_file => /(folder|file)/ }

  map.notify '/jobs/notify', :controller => 'jobs', :action => 'notify'
  map.resources :interactive_classes
  map.resources :statuses
  map.resources :lessons
  map.resources :beta_keys, :collection => {:generate => :get, :remove_all => :get, :print_blank => :get, :invite => [:get, :post]}
  map.resources :profiles
  map.resources :subjects, :member => {:enroll => :get, :upload => :get, :download => :get}, :collection => {:cancel => :get} do |subject|
  subject.resources :events, :member => { :vote => [:post,:get], :notify => :post }, :collection => { :past => :get, :ical => :get , :day => :get}
  subject.resources :bulletins, :member => {:rate => :post}
  end
 
  map.admin_subjects "admin/subjects", :controller => "subjects", :action => "admin_subjects" 
  map.admin_show "admin/show/:id", :controller => "subjects", :action => "admin_show" 
  map.resources :questions, :collection => { :search => [:get, :post], :add => :get } 
  map.resources :exams, :member => {:add_question => :get, :add_resource => :get, :rate => :post, :answer => [:get,:post]},
      :collection => {:unpublished_preview => :get, :unpublished => :get, :new_exam => :get, :cancel => :get, 
      :exam_history => :get, :sort => :get, :order => :get, :questions_database => :get,
      :review_question => :get}
  map.resources :lectures, :member => {:rate => :post, :buy => :get, :download_attachment => :get},  
    :collection => { :unpublished_preview => :get, :cancel => :get, :sort_lesson => :post, :unpublished => :get,:waiting => :get}
  map.resources :credits
  map.resources :folders
  map.resources :annotations
  map.resources :bulletins, :member => {:rate => :post}
  map.resources :events#, :collection => { :past => :get, :ical => :get }
  map.resources :sb_posts
  map.resources :topics
  map.resources :metro_areas  
  map.resources :invitations
  
  # Index
  map.learn_index '/learn', :controller => 'base', :action => 'learn_index'
  map.teach_index '/teach', :controller => 'base', :action => 'teach_index'

  if AppConfig.closed_beta_mode
    map.connect '', :controller => "base", :action => "beta_index"
    map.home 'home', :controller => "base", :action => "site_index"
  else
    map.home '', :controller => "base", :action => "site_index"
  end
  map.application '', :controller => "base", :action => "site_index"

  map.resources :tags, :member_path => '/tags/:id'
  map.show_tag_type '/tags/:id/:type', :controller => 'tags', :action => 'show'
  map.search_tags '/search/tags', :controller => 'tags', :action => 'show'

  # admin routes
  map.admin_dashboard   '/admin/dashboard', :controller => 'admin', :action => 'dashboard'
  map.admin_moderate_submissions   '/admin/moderate/submissions', :controller => 'admin', :action => 'submissions'
  map.admin_moderate_lectures   '/admin/moderate/lectures', :controller => 'admin', :action => 'lectures'
  map.admin_moderate_users   '/admin/moderate/users', :controller => 'admin', :action => 'users'
  map.admin_moderate_exams   '/admin/moderate/exams', :controller => 'admin', :action => 'exams'
  map.admin_moderate_spaces   '/admin/moderate/spaces', :controller => 'admin', :action => 'spaces'

  map.admin_users       '/admin/users', :controller => 'admin', :action => 'users'
  map.admin_messages    '/admin/messages', :controller => 'admin', :action => 'messages'
  map.admin_comments    '/admin/comments', :controller => 'admin', :action => 'comments'
  map.admin_tags        'admin/tags/:action', :controller => 'tags', :defaults => {:action=>:manage}
  map.admin_events      'admin/events', :controller => 'admin', :action=>'events'

  # sessions routes
  map.teaser '', :controller=>'base', :action=>'beta_index'
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup_by_id '/signup/:inviter_id/:inviter_code', :controller => 'users', :action => 'new'

  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.forgot_username '/forgot_username', :controller => 'users', :action => 'forgot_username'
  map.resend_activation '/resend_activation', :controller => 'users', :action => 'resend_activation'
  map.edit_account_from_email '/account/edit', :controller => 'users', :action => 'edit_account'
  map.resources :sessions

  # RSS
  map.featured '/featured', :controller => 'posts', :action => 'featured'
  map.featured_rss '/featured.rss', :controller => 'posts', :action => 'featured', :format => 'rss'
  map.popular '/popular', :controller => 'posts', :action => 'popular'
  map.popular_rss '/popular.rss', :controller => 'posts', :action => 'popular', :format => 'rss'
  map.recent '/recent', :controller => 'posts', :action => 'recent'
  map.recent_rss '/recent.rss', :controller => 'posts', :action => 'recent', :format => 'rss'
  map.rss_redirect '/rss', :controller => 'base', :action => 'rss_site_index'
  map.rss '/site_index.rss', :controller => 'base', :action => 'site_index', :format => 'rss'

  # site routes
  map.about '/about', :controller => 'base', :action => 'about'
  map.faq '/faq', :controller => 'base', :action => 'faq'
  map.removed_page   '/removed_item', :controller => 'base', :action => 'removed_item'
  map.contact 'contact',  :controller => 'base', :action => 'contact'

  # SCHOOL
  map.resources :spaces, :member => {
    :join => :get,
    :vote => :post,
    :unjoin => :get,
    :manage => :get,
    :admin_members => :get,
    :admin_bulletins => :get,
    :admin_events => :get,
    :look_and_feel => :get,
    :members => :get,
    :teachers => :get,
    :take_ownership => :get,
    :remove_asset => :get
  },
    :collection =>{
    :cancel => :get
  } do |space|
    space.resources :folders,
      :member => { :upload => :get,
                   :download => :get,
                   :rename => :get,
                   :destroy_folder => :delete,
                   :destroy_file => :delete }
    space.resources :subjects
    space.resources :bulletins
    space.resources :events,
      :member => { :vote => [:post,:get], :notify => :post },
      :collection => { :past => :get, :ical => :get , :day => :get }
    space.resource :forum, :except => [ :new, :edit, :create, :update, :destroy ] do |forum|
      forum.resources :topics do |topic|
        topic.resources :sb_posts
      end
      forum.resources :sb_posts, :except => [:new, :edit, :create, :update, :destroy]
    end 
 end

  # USERS
  map.resources :users, :member => {
  #map.resources :users, :member_path => '/:id', :nested_member_path => '/:user_id', :member => {
    :annotations => :get,
    :followers => :get,
    :follows => :get,
    :follow => :post,
    :activity_xml => :get,
    :logs => :get,
    :unfollow => :post,
    :assume => :get,
    :toggle_moderator => :put,
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
    :learning => :get,
    :teaching => :get,
    :deactivate => :put,
    :crop_profile_photo => [:get, :put],
    :upload_profile_photo => [:get, :put]
  } do |user|
    user.resources :friendships, :member => { :accept => :put, :deny => :put }, :collection => { :accepted => :get, :pending => :get, :denied => :get }
    user.resources :photos, :collection => {:swfupload => :post, :slideshow => :get}
    user.resources :posts, :collection => {:manage => :get}, :member => {:contest => :get, :send_to_friend => :any, :update_views => :any}
    user.resources :events # Needed this to make comments work
    #user.resources :clippings
    user.resources :activities, :collection => {:network => :get}
    user.resources :invitations
    user.resources :lectures, :collection => {:published => :get, :unpublished => :get, :waiting => :get}
    user.resources :spaces, :collection => {:member => :get, :owner => :get}
    user.resources :exams, :collection => {:published => :get, :unpublished => :get, :history => :get}
    user.resources :questions
    user.resources :credits
    user.resources :offerings, :collection => {:replace => :put}
    user.resources :favorites
    user.resources :messages, :collection => { :delete_selected => :post, :auto_complete_for_username => :any }
    user.resources :comments
    user.resources :photo_manager, :only => ['index']
    user.resources :albums, :path_prefix => ':user_id/photo_manager', :member => {:add_photos => :get, :photos_added => :post}, :collection => {:paginate_photos => :get}  do |album|
      album.resources :photos, :collection => {:swfupload => :post, :slideshow => :get}
    user.resources :statuses
    user.admin_roles '/:environment_id/roles',
      :controller => :roles, :action => :show, :conditions => {:method => :get}
    user.update_roles '/:environment_id/roles',
      :controller => :roles, :action => :update, :conditions => {:method => :post}
    end
  end

  map.resources :environments,
    :member_path => ":id",
    :nested_member_path => "/:environment_id",
    :member => { :preview => :get,
                 :admin_courses => :get,
                 :admin_members => :get,
                 :destroy_members => :post } do |environment|
      environment.resources :courses, :member => {
        :preview => :get,
        :admin_spaces => :get,
        :admin_members_requests => :get,
        :join => :get,
        :unjoin => :get,
        :publish => :get,
        :unpublish => :get,
        :admin_members => :get,
        :destroy_members => :post
      }
      environment.resources :bulletins
  end

  map.resources :courses do |course|
    course.resources :invitations
  end

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
#ActionController::Routing::Translator.i18n('pt-BR') # se ativar, buga (falar com cassio)
ActionController::Routing::Translator.translate_from_file('lang','i18n-routes.yml')
