Rails.application.routes.draw do
  namespace :api do
    namespace :users do
      post '/signup',                        to: 'api/signup#signup'
      post '/activation',                    to: 'api/verify_email#activate_account'
      post '/login',                         to: 'api/login#login'
      delete '/logout',                      to: 'api/logout#logout'
      get '/:id',                            to: 'api/account#show'
      put '/:id/password',                   to: 'api/account#update_password'
      put '/:id/profile',                    to: 'api/account#update_profile'
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
