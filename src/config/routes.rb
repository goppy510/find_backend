# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  namespace :api do
    namespace :users do
      post '/signup',      to: 'signup#signup'
      post '/activation',  to: 'activation#activate'
      post '/profile',     to: 'profile#create'
      put  '/profile',     to: 'profile#update'
      post '/login',       to: 'login#create'
      delete '/logout',    to: 'login#destroy'
      get '/profile',      to: 'profile#show'
      put '/:id/password', to: 'profile#update_password'
    end

    namespace :prompts do
      # get '/',            to: 'prompt#index'
      # post '/',           to: 'prompt#create'
      # get '/:id',         to: 'prompt#show'
      # put '/:id',         to: 'prompt#update'
      # delete '/:id',      to: 'prompt#destroy'
      # post '/:id/like',   to: 'prompt#like'
      # delete '/:id/like', to: 'prompt#unlike'
      get '/categories',  to: 'category#index'
    end
  end
end
