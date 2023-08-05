Rails.application.routes.draw do
  namespace :api do
    namespace :users do
      post '/signup',                        to: 'api/signup#signup'
      post '/activation',                    to: 'api/activation#activate'
      post '/profile',                       to: 'api/profile#create'
      put '/:id/profile',                    to: 'api/profile#update'
      post '/login',                         to: 'api/login#create'
      delete '/logout',                      to: 'api/login#destroy'
      get '/:id/profile',                    to: 'api/profile#show'
      put '/:id/password',                   to: 'api/profile#update_password'
      post '/session',                       to: 'api/session#create'
      delete '/session/:id',                 to: 'api/session#destroy'  
    end

    namespace :prompts do
      get '/',       to: 'api/prompts#index'
      post '/',      to: 'api/prompts#create'
      get '/:id',    to: 'api/prompts#show'
      put '/:id',    to: 'api/prompts#update'
      delete '/:id', to: 'api/prompts#destroy'
      post '/:id/like', to: 'prompts#like'
      delete '/:id/like', to: 'prompts#unlike'
    end
  end
end
