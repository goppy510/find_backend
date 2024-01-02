# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  namespace :api do
    # ユーザ個人
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
      resources :login, only: [:create]

      # PUT /api/users/password/:id
      resources :password, only: [:update]
    end

    # GET /api/users
    # GET /api/users/:user_id
    # DELETE /api/users/:user_id
    resources :users, only: [:index, :show, :destroy]

    # POST /api/permissions
    # GET /api/permissions/:user_id
    # DELETE /api/permissions/:user_id
    resources :permissions, only: [:create, :show, :destroy]

    # POST /api/prompts
    # GET /api/prompts
    # GET /api/prompts/:uuid
    # PUT /api/prompts/:uuid
    # DELETE /api/prompts/:uuid
    resources :prompts, only: [:index, :create, :show, :update, :destroy] do
      member do
        # POST /api/prompts/:prompt_id/like
        post :like
        # DELETE /api/prompts/:prompt_id/like
        delete :like, action: :dislike
        # GET /api/prompts/:prompt_id/like
        get :like, action: :like_count
        # POST /api/prompts/:prompt_id/bookmark
        post :bookmark
        # DELETE /api/prompts/:prompt_id/bookmark
        delete :bookmark, action: :disbookmark
        # GET /api/prompts/:prompt_id/bookmark
        get :bookmark, action: :bookmark_count
      end
    end
    namespace :prompts do
      # GET /api/prompts/categories
      resources :categories, only: [:index]
    end
  end
end
