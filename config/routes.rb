Rails.application.routes.draw do
  namespace :api do
    namespace :users do
      post '/signup',                        to: 'api/user#signup'
      post '/submission_verify_mail/:token', to: 'api/user#submit_verify_email'
      post '/activation',                    to: 'api/user#activate_account'
      post '/login',                         to: 'api/user#login'
      delete '/logout',                      to: 'api/user#logout'
      get '/:id',                            to: 'api/user#show'
      put '/:id/password',                   to: 'api/user#update_password'
      put '/:id/profile',                    to: 'api/user#update_profile'
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
