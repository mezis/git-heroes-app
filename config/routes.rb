require 'resque/server'

Rails.application.routes.draw do
  root to: 'homepage#show'

  resource :session, only: %i[show destroy], path: 'auth/github' do
    get 'callback'
    post 'callback'
    get 'failure'
  end

  mount Resque::Server.new, at: '/resque'

  match '/_orgs'                                => 'organisations#index',   via: %i[get],       as: 'organisations'
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
  match '/:organisation_id/:id'                 => 'repositories#update',   via: %i[patch put], as: 'organisation_repository'
  match '/:organisation_id/_metrics/:id'        => 'metrics#show',          via: %i[get],       as: 'organisation_metric'
end
