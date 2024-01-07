# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  namespace :api do
    # ユーザ個人
    namespace :users do
      post '/signup', to: 'signup#create'

      post '/activation', to: 'activation#create'

      post '/profile', to: 'profile#create'
      put '/profile/:user_id', to: 'profile#update'
      get '/profile/:user_id', to: 'profile#show'

      post '/login', to: 'login#create'

      put '/password/:user_id', to: 'password#update'

      post '/', to: 'user#create'
      get '/', to: 'user#index'
      get '/:user_id', to: 'user#show'
      delete '/:user_id', to: 'user#destroy'
    end

    post '/contracts', to: 'contract#create'
    get '/contracts', to: 'contract#index'
    get '/contracts/:user_id', to: 'contract#show'
    put '/contracts/:user_id', to: 'contract#update'
    delete '/contracts/:user_id', to: 'contract#destroy'

    post '/permissions', to: 'permissions#create'
    get '/permissions/:user_id', to: 'permissions#show'
    delete '/permissions/:user_id', to: 'permissions#destroy'

    post '/prompts', to: 'prompts#create'
    get '/prompts', to: 'prompts#index'
    get '/prompts/:uuid', to: 'prompts#show'
    put '/prompts/:uuid', to: 'prompts#update'
    delete '/prompts/:uuid', to: 'prompts#destroy'

    post '/prompts/:prompt_id/like', to: 'prompts#like'
    delete '/prompts/:prompt_id/like', to: 'prompts#dislike'
    get '/prompts/:prompt_id/like', to: 'prompts#like_count'
    
    post '/prompts/:prompt_id/bookmark', to: 'prompts#bookmark'
    delete '/prompts/:prompt_id/bookmark', to: 'prompts#disbookmark'
    get '/prompts/:prompt_id/bookmark', to: 'prompts#bookmark_count'
  end
end
