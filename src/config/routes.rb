# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  namespace :api do
    namespace :users do
      # POST /api/users/signup
      resources :signup, only: [:create]

      # POST /api/users/activation
      resources :activation, only: [:create]

      # POST /api/users/profile/
      # PUT /api/users/profile/:id
      # GET /api/users/profile/:id
      resources :profile, only: [:create, :update, :show]

      # POST /api/users/login
      # DELETE /api/users/login
      resources :login, only: [:create, :destroy]

      # PUT /api/users/profile/password/:id
      resources :profile, only: [:update]
    end

    # POST /api/contracts/:contract_id/users
    # GET /api/contracts/:contract_id/users
    # GET /api/contracts/:contract_id/users/:user_id
    # DELETE /api/contracts/:contract_id/users/:user_id
    namespace :contracts do
      resources :contracts do
        resources :users, only: [:create, :index, :show, :destroy], param: :user_id
      end
    end

    # POST /api/prompts
    # GET /api/prompts
    # GET /api/prompts/:uuid
    # PUT /api/prompts/:uuid
    # DELETE /api/prompts/:uuid
    resources :prompts, only: [:index, :create, :show, :update, :destroy]

    namespace :prompts do
      # GET /api/prompts/categories
      resources :categories, only: [:index]
    end
  end
end
