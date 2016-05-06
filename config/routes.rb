require 'resque/server'

Rails.application.routes.draw do
  root to: 'homepage#show'

  resource :session, only: %i[show destroy], path: 'auth/github' do
    get 'callback'
    post 'callback'
    get 'failure'
  end
  # get  '/auth/github'          => 'sessions#new' # convenience
  # get  '/auth/github/callback' => 'sessions#create'
  # post '/auth/github/callback' => 'sessions#create'
  # get  '/auth/failure'         => 'sessions#abort'

  resource :homepage, only: %i[show]

  match '/:id'                                  => 'organisations#show',    via: %i[get],       as: 'organisation'
  match '/:id'                                  => 'organisations#update',  via: %i[patch put]
  match '/:organisation_id/_teams'              => 'teams#index',           via: %i[get],       as: 'organisation_teams'
  match '/:organisation_id/_teams'              => 'teams#update',          via: %i[patch put]
  match '/:organisation_id/_teams/:id'          => 'teams#show',            via: %i[get],       as: 'organisation_team'
  match '/:organisation_id/_teams/:id'          => 'teams#update',          via: %i[patch put]
  match '/:organisation_id/_repos'              => 'repositories#index',    via: %i[get],       as: 'organisation_repositories'
  match '/:organisation_id/_repos'              => 'repositories#update',   via: %i[patch put]
  match '/:organisation_id/_members'            => 'users#index',           via: %i[get],       as: 'organisation_users'
  match '/:organisation_id/@:id'                => 'users#show',            via: %i[get],       as: 'organisation_user'
  match '/:organisation_id/:id'                 => 'repositories#show',     via: %i[get],       as: 'organisation_repository'
  match '/:organisation_id/:id'                 => 'repositories#update',   via: %i[patch put]
  match '/:organisation_id/_metrics/:id'        => 'metrics#show',          via: %i[get],       as: 'organisation_metric'

  mount Resque::Server.new, at: '/resque'
  # get 'sessions/create'
  # get 'sessions/destroy'
  # get 'sessions/abort'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
