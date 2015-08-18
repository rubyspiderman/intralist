IntralistApp::Application.routes.draw do
  
  delete "user/authorizations/destroy", :to => "users/authorizations#destroy", :as => 'disconnect'

  devise_scope :user do
    get "/users/auth/:provider/callback", :to => "users/authorizations#create"
    get "/users/authorizations", :to => "users/authorizations#index"
  end

  get "unsubscribe", :to => "users/unsubscribe#unsubscribe"

  devise_for :users,
             :controllers => { :omniauth_callbacks => 'users/authorizations', :registrations => 'users/registrations'

                             },
             :path_names => { :sign_in => 'login', :sign_out => 'logout',
                              :password => 'secret', :confirmation => 'verification', :unlock => 'unblock',
                              :registration => 'register'}

  namespace :api, defaults: {format: :json} do
    resources :intralists, only: [:create, :show, :index]
    resources :items, only: [:create, :update, :destroy]
    resources :requests, only: [:index, :create, :show, :update, :destroy]
    resources :shares, only: :create
    resources :image_uploads, only: :create
    resources :lists, only: [:index, :create, :update, :destroy], module: 'lists' do
      resource :like, only: [:create]
      resources :bookmark, only: [:create, :destroy, :index]
      resources :items, only: [:create, :update, :destroy]
      resources :comments, only: [:index, :create, :update, :destroy]
      resources :copies, only: [:index]
      resources :requests
    end
    resources :users do
      resources :follows, only: [:index, :create, :destroy], :controller => "users/follows"
      resources :followers, only: [:index], :controller => "users/followers"
      resources :notifications, only: [:index, :destroy], :controller => "users/notifications"
      resource :profile, only: [:show, :edit, :update], :controller => "users/profile"
      resource :bookmarks, only: [:show], :controller => "users/bookmarks"
    end

    resources :list_groups, only: [:index, :show]

  end

  delete 'api/notifications', :to => "api/notifications#destroy"
  resource :search, :only => [:show], :controller => 'search'

  authenticated :user do
    root :to => "lists#index"
  end

  resources :users do
    resources :friends, :controller => 'users/friends' do
      collection do
        get :find_friends
      end
    end
  end
  resources :lists
  resources :requests

  # http://intralist.dev/users/aressidi/friends
  # http://intralist.dev/users/register/edit.aressidi
  # new_user_password
  # edit_user_password
  # edit_user_registration_path(current_user)

  #NOTE:  When deleting a comment off an intralist we need to pass
  #intralist=true, but DELETE doesn't support a request body.

  # Logout a user with just 'logout'
  # devise_scope :user do
    # get "/logout" => "devise/sessions#destroy"
  # end

  match '/api/lists/:list_id/comments/:id', :via => [:post], :controller => 'api/lists/comments', :action => 'destroy'
  match '/api/lists/unique_by_intralist', :via => [:post], :controller => 'api/lists/lists', :action => 'unique_by_intralist'
  match "*anything" => "lists#index"
  root :to => "lists#index"
end
