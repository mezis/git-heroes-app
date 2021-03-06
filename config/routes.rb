require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :admin do
    resources :users,         only: %i[index]
    resources :organisations, only: %i[index]
  end

  root to: 'homepage#show'

  resource :session, only: %i[show destroy update], path: 'auth/github' do
    get 'intermission', as: 'intermission'
    get 'callback'
    post 'callback'
    get 'failure'
  end

  mount Rack::Builder.new {
    use Rack::Auth::Basic do |*credentials|
      credentials.last == ENV['JOBS_HTTP_PASSWORD']
    end
    # run Resque::Server.new
    run Sidekiq::Web
  }, at: '/admin/jobs', as: 'admin_jobs'

  match '/_jobs'                                => 'background_jobs#index',     via: %i[get],       as: 'background_jobs'
  match '/_events'                              => 'events#create',             via: %i[post],      as: 'events'
  match '/_users/@:id'                          => 'users#show',                via: %i[get],       as: 'user'
  match '/_users/@:id'                          => 'users#update',              via: %i[patch put]
  match '/_users/@:id/settings'                 => 'user_settings#update',      via: %i[patch put], as: 'user_setting'
  match '/_orgs'                                => 'organisations#index',       via: %i[get],       as: 'organisations'
  match '/:id'                                  => 'organisations#show',        via: %i[get],       as: 'organisation'
  match '/:id'                                  => 'organisations#update',      via: %i[patch put]
  match '/:organisation_id/_chord'              => 'team_metrics#show',         via: %i[get],       as: 'organisation_chord'
  match '/:organisation_id/_teams'              => 'teams#index',               via: %i[get],       as: 'organisation_teams'
  match '/:organisation_id/_teams'              => 'teams#update',              via: %i[patch put]
  match '/:organisation_id/_teams/:id/'         => 'teams#show',                via: %i[get],       as: 'organisation_team'
  match '/:organisation_id/_teams/:id/'         => 'teams#update',              via: %i[patch put]
  match '/:organisation_id/_teams/:id/_chord'   => 'team_metrics#show',         via: %i[get],       as: 'organisation_team_metrics'
  match '/:organisation_id/_repos'              => 'repositories#index',        via: %i[get],       as: 'organisation_repositories'
  match '/:organisation_id/_repos'              => 'repositories#update',       via: %i[patch put]
  match '/:organisation_id/_members'            => 'users#index',               via: %i[get],       as: 'organisation_users'
  match '/:organisation_id/@:id'                => 'users#show',                via: %i[get],       as: 'organisation_user'
  match '/:organisation_id/@:id'                => 'organisation_users#update', via: %i[patch put]
  match '/:organisation_id/:id'                 => 'repositories#show',         via: %i[get],       as: 'organisation_repository'
  match '/:organisation_id/:id'                 => 'repositories#update',       via: %i[patch put]
  match '/:organisation_id/_metrics/:id'        => 'metrics#show',              via: %i[get],       as: 'organisation_metric'
end
