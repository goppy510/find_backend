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
      # プロンプトのCRUD
      get '/',         to: 'prompt#index'
      post '/',        to: 'prompt#create'
      get '/:uuid',    to: 'prompt#show'
      put '/:uuid',    to: 'prompt#update'
      delete '/:uuid', to: 'prompt#delete'

      # いいね・ブックマーク
      post '/:prompt_id/like',       to: 'prompt#like'
      delete '/:prompt_id/like',     to: 'prompt#dislike'
      post '/:prompt_id/bookmark',   to: 'prompt#bookmark'
      delete '/:prompt_id/bookmark', to: 'prompt#disbookmark'

      # カテゴリの検索
      get '/categories',  to: 'category#index'
    end
  end
end
