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

  resources :organisations, only: %i[index show update] do
    resources :users,              only: %i[index show]
    resources :repositories,       only: %i[index update]
    resource  :repositories,       only: %i[update]
    resources :teams,              only: %i[index show update] 
    resource  :teams,              only: %i[update]
    resources :metrics,            only: %i[show]
  end

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
