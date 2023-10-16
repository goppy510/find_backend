# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  namespace :api do
    namespace :users do
      # 一般的な会員登録のAPI
      post '/signup',      to: 'signup#signup'
      # contract権限を持つ人が契約を作成する場合のAPI
      post '/admin_signup', to: 'admin_signup#signup'

      post '/activation',  to: 'activation#activate'

      post '/profile',     to: 'profile#create'
      put  '/profile',     to: 'profile#update'
      get '/profile',      to: 'profile#show'

      post '/login',       to: 'login#create'
      delete '/logout',    to: 'login#destroy'

      put '/:id/password', to: 'profile#update_password'

      # メンバー
      post '/user',        to: 'user#create'
      get '/user',         to: 'user#show'
      delete '/user',      to: 'user#delete'

      # 権限
      post '/permission',   to: 'permission#create'
      get '/permission',    to: 'permission#show'
      delete '/permission', to: 'permission#delete'
    end

    namespace :prompts do
      # カテゴリの検索
      get '/categories',  to: 'category#index'

      # いいね・ブックマーク
      post '/:prompt_id/like',       to: 'prompt#like'
      delete '/:prompt_id/like',     to: 'prompt#dislike'
      get '/:prompt_id/like',        to: 'prompt#like_count'
      post '/:prompt_id/bookmark',   to: 'prompt#bookmark'
      delete '/:prompt_id/bookmark', to: 'prompt#disbookmark'
      get '/:prompt_id/bookmark',    to: 'prompt#bookmark_count'

      # プロンプトのCRUD
      get '/',         to: 'prompt#index'
      post '/',        to: 'prompt#create'
      get '/:uuid',    to: 'prompt#show'
      put '/:uuid',    to: 'prompt#update'
      delete '/:uuid', to: 'prompt#delete'
    end
  end
end
