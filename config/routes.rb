Redu::Application.routes.draw do

  post "presence/auth"
  post "presence/multiauth"
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

  # site routes
  match '/about' => 'base#about', :as => :about
  match '/faq' => 'base#faq', :as => :faq
  match 'contact' => 'base#contact', :as => :contact

  # Space
  resources :spaces, :except => [:index] do
    member do
      get :admin_members
      get :publish
      get :unpublish
      get :mural
      get :students_endless
      get :admin_subjects
    end

    resources :folders, :only => [:update, :create, :index] do
      member do
        get :upload
        get :download
        get :rename
        delete :destroy_folder
        delete :destroy_file
        post :do_the_upload
        put :do_the_upload
      end
    end

    resources :subjects, :except => [:index] do
      resources :lectures do
        member do
          post :rate
          post :done
        end
      end
    end

    resources :users, :only => [:index]
 end

  resources :exercises, :only => :show do
    resources :results, :only => [:index, :create, :update, :edit]
    resources :questions, :only => :show do
      resources :choices, :only => [:create, :update]
    end
  end

  # Users
  resources :users, :except => [:index] do
    member do
      get :edit_account
      put :update_account
      get :forgot_password
      post :forgot_password
      get :signup_completed
      get :invite
      put :deactivate
      get :home
      get :my_wall
      get :account
      get :contacts_endless
      get :environments_endless
      get :show_mural
      get :curriculum
    end
    collection do
      get :auto_complete
    end

    resources :social_networks, :only => [:destroy]

    resources :friendships, :only => [:index, :create, :destroy]

    resources :invitations

    resources :favorites, :only => [] do
      member do
        post :favorite
        post :not_favorite
      end
    end

    resources :messages, :except => [:destroy, :edit, :update] do
      collection do
        get :index_sent
        post :delete_selected
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

    resources :invoices, :only => [:index, :show]
  end

  match '/payment/callback' => 'payment_gateway#callback',
    :as => :payment_callback
  match '/payment/success' => 'payment_gateway#success', :as => :payment_success

  resources :partners, :only => [:show, :index] do
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
      post :destroy_members
      post :search_users_admin
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
        post :accept
        post :deny
      end

      resources :users, :only => [:index]
      resources :user_course_invitations, :only => [:show]
    end

    resources :users, :only => [:index]
  end


  root :to => 'base#site_index', :as => :home
  root :to => "base#site_index", :as => :application

end

ActionDispatch::Routing::Translator.translate_from_file('lang','i18n-routes.yml')
