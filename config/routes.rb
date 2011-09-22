Redu::Application.routes.draw do

  post "presence/auth"
  post "presence/send_chat_message"
  get "presence/last_messages_with"

  match 'clipboard/:action/:folder_or_file/:id' => 'clipboard',
    :constraints => { :action         => /(add|remove)/,
                       :folder_or_file => /(folder|file)/ }
  match '/jobs/notify' => 'jobs#notify', :as => :notify
  resources :statuses, :only => [:create, :destroy] do
    member do
      post :respond
    end
  end
  resources :profiles
  resources :questions do
    collection do
      get :search
      post :search
      get :add
    end
  end
  resources :folders
  resources :annotations
  resources :bulletins do
    member do
      post :rate
    end
  end
  resources :sb_posts
  resources :topics
  resources :metro_areas

  resources :tags
  match '/tags/:id/:type' => 'tags#show', :as => :show_tag_type
  match '/search/tags' => 'tags#show', :as => :search_tags

  match 'admin/tags/:action' => 'tags', :action => :manage, :as => :admin_tags

  # sessions routes
  match '/signup' => 'users#new', :as => :signup
  match '/logout' => 'sessions#destroy', :as => :logout

  match '/forgot_password' => 'users#forgot_password', :as => :forgot_password
  match '/forgot_username' => 'users#forgot_username', :as => :forgot_username
  match '/resend_activation' => 'users#resend_activation',
    :as => :resend_activation
  match '/account/edit' => 'users#edit_account', :as => :edit_account_from_email
  resources :sessions

  # RSS
  match '/featured' => 'posts#featured', :as => :featured
  match '/featured.rss' => 'posts#featured', :format => 'rss', :as => :featured_rss
  match '/popular' => 'posts#popular', :as => :popular
  match '/popular.rss' => 'posts#popular', :format => 'rss', :as => :popular_rss
  match '/recent' => 'posts#recent', :as => :recent
  match '/recent.rss' => 'posts#recent', :format => 'rss', :as => :recent_rss
  match '/rss' => 'base#rss_site_index', :as => :rss_redirect
  match '/site_index.rss' => 'base#site_index', :format => 'rss', :as => :rss


  # site routes
  match '/about' => 'base#about', :as => :about
  match '/faq' => 'base#faq', :as => :faq
  match '/removed_item' => 'base#removed_item', :as => :removed_page
  match 'contact' => 'base#contact', :as => :contact

  resources :events

  # Space
  resources :spaces, :except => [:index] do
    member do
      get :manage
      get :admin_members
      get :admin_bulletins
      get :admin_events
      get :look_and_feel
      get :teachers
      get :take_ownership
      get :publish
      get :unpublish
      get :users
      get :mural
      post :moderate_bulletins
      post :moderate_events
    end
    collection do
      get :cancel
    end

    resources :folders do
      member do
        get :upload
        get :download
        get :rename
        delete :destroy_folder
        delete :destroy_file
        post :do_the_upload
        put :do_the_upload
        post :update_permissions
      end
    end

    resources :subjects do
      member do
        post :turn_visible
        post :turn_invisible
        get :admin_lectures_order
        post :admin_lectures_order
        get :statuses
        get :users
        get :admin_members
      end
      collection do
        get :cancel
      end

      resources :lectures do
        member do
          post :rate
          post :done
        end
        collection do
          get :unpublished_preview
          get :cancel
          get :unpublished
          get :published
        end
      end

      resources :exams do
        member do
          get :add_question
          get :add_resource
          post :rate
          get :answer
          post :answer
          get :compute_results
          get :results
          get :review_question
        end
        collection do
          get :unpublished
          get :published
          get :history
          get :new_exam
          get :cancel
          get :exam_history
          get :sort
          get :order
          get :questions_database
          get :review_question
        end
      end
    end

    resources :bulletins do
      member do
        get :vote
        post :vote
      end
    end

    resources :events do
      member do
        get :vote
        post :vote
        post :notify
      end
      collection do
        get :past
        get :ical
        get :day
      end
    end

    resource :forum, :except => [:new, :edit, :create, :update, :destroy] do
      resources :topics do
        resources :sb_posts
      end
      resources :sb_posts, :except => [:new, :edit, :create, :update, :destroy]
    end
 end

  # Users
  resources :users, :except => [:index] do
    member do
      get :annotations
      get :activity_xml
      get :logs
      get :assume
      put :change_profile_photo
      get :edit_account
      put :update_account
      get :edit_pro_details
      put :update_pro_details
      get :forgot_password
      post :forgot_password
      get :signup_completed
      get :invite
      get :welcome_complete
      get :learning
      put :deactivate
      get :crop_profile_photo
      put :crop_profile_photo
      get :upload_profile_photo
      put :upload_profile_photo
      get :home
      get :mural
      get :account
      get :contacts_endless
      get :environments_endless
      get :show_mural
    end
    collection do
      get :auto_complete
    end

    resources :social_networks, :only => [:destroy]

    resources :friendships, :only => [:index, :create, :destroy] do
      member do
        post :accept
        post :decline
      end
      collection do
        get :pending
      end
    end

    resources :photos do
      collection do
        post :swfupload
        get :slideshow
      end
    end

    resources :posts do
      collection do
        get :manage
      end
      member do
        get :contest
        match :send_to_friend
        match :update_views
      end
    end

    resources :events # Needed this to make comments work

    resources :activities do
      collection do
        get :network
      end
    end

    resources :invitations

    resources :questions
    resources :offerings do
      collection do
        put :replace
      end
    end

    resources :favorites, :only => [:index] do
      member do
        post :favorite
        post :not_favorite
      end
    end

    resources :messages do
      collection do
        get :index_sent
        post :delete_selected
      end
    end

    resources :comments

    resources :photo_manager, :only => ['index']

    scope ":user_id/photo_manager" do
      resources :albums do
        member do
          get :add_photos
          post :photos_added
        end
        collection do
          get :paginate_photos
        end

        resources :photos do
          collection do
            post :swfupload
            get :slideshow
          end
        end
      end
    end

    resources :plans, :only => [:index]
    resources :experiences
    resources :educations, :except => [:new, :edit]
    get '/:environment_id/roles' => 'roles#show', :as => :admin_roles
    post '/:environment_id/roles' => 'roles#update', :as => :update_roles
  end

  match 'users/activate/:id' => 'users#activate', :as => :activate

  # Indexes
  match 'privacy' => "base#privacy", :as => :privacy
  match 'tos' => "base#tos", :as => :tos
  match 'contact' => "base#contact", :as => :contact
  match '/teach' => 'base#teach_index', :as => :teach_index
  match '/courses' => 'courses#index', :as => :courses_index, :via => :get

  resources :plans, :only => [] do
    member do
      get :confirm
      post :confirm
      get :upgrade
      post :upgrade
    end

    resources :invoices, :only => [:index]
  end

  match '/payment/callback' => 'payment_gateway#callback',
    :as => :payment_callback
  match '/payment/success' => 'payment_gateway#success', :as => :payment_success

  resources :partners, :only => [:show] do
    member do
      post :contact
      get :success
    end

    resources :partner_environment_associations, :as => :clients,
      :only => [:create, :index, :new]
    resources :partner_user_associations, :as => :collaborators, :only => :index
  end

  resources :environments, :path => '', :except => [:index] do
    member do
      get :preview
      get :admin_courses
      get :admin_members
      get :admin_bulletins
      post :destroy_members
      post :search_users_admin
      get :users
    end
    resources :courses do
      member do
        get :preview
        get :admin_spaces
        get :admin_members_requests
        get :admin_invitations
        get :admin_manage_invitations
        post :invite_members
        post :accept
        post :join
        post :unjoin
        get :publish
        get :unpublish
        get :admin_members
        post :destroy_members
        post :destroy_invitations
        post :search_users_admin
        post :moderate_members_requests
        get :users
        post :accept
        post :deny
      end

      resources :user_course_invitations, :only => [:show]
    end
    resources :bulletins do
      member do
        get :vote
        post :vote
      end
    end
  end


  root :to => 'base#site_index', :as => :home
  root :to => "base#site_index", :as => :application

  match '/:anything', :to => "application#routing_error", :constraints => { :anything => /.*/ }
end

ActionDispatch::Routing::Translator.translate_from_file('lang','i18n-routes.yml')
