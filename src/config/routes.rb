# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  namespace :api do
    namespace :users do
      post '/signup',      to: 'signup#signup'
      post '/activation',  to: 'activation#activate'
      post '/profile',     to: 'profile#create'
      put '/:id/profile',  to: 'profile#update'
      post '/login',       to: 'login#create'
      delete '/logout',    to: 'login#destroy'
      get '/profile',      to: 'profile#show'
      put '/:id/password', to: 'profile#update_password'
    end

    namespace :prompts do
      get '/',       to: 'prompts#index'
      post '/',      to: 'prompts#create'
      get '/:id',    to: 'prompts#show'
      put '/:id',    to: 'prompts#update'
      delete '/:id', to: 'prompts#destroy'
      post '/:id/like', to: 'prompts#like'
      delete '/:id/like', to: 'prompts#unlike'
    end
  end
end
