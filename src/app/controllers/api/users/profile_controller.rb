# frozen_string_literal: true

module Api
  module Users
    class ProfileController < ApplicationController
      include SessionModule
      before_action :cookie_token?

      # プロフィール作成
      def create
        user_id = @auth[:user_id]
        valid_profiles = { profiles: profile_params.to_unsafe_h }
        ProfileService.create(user_id, valid_profiles)
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # プロフィール更新用
      def update
        user_id = @auth[:user_id]
        ProfileService.update_profiles(user_id, params[:profiles])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # パスワード更新用
      def update_password
        user_id = @auth[:user_id]
        ProfileService.update_password(user_id, password_params[:current_password], password_params[:new_password])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # ユーザー情報閲覧用
      def show
        user_id = @auth[:user_id]
        res = ProfileService.show(user_id)
        render json: { status: 'success', data: res }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      private

      def cookie_token?
        authenticate_user(cookie_token)
        return true if @auth.present?

        render_error(400, 'user', 'invalid_token')
      end

      def profile_params
        params.require(:profiles).permit(
          :name,
          :phone_number,
          :company_name,
          :employee_count,
          :industry,
          :position,
          :business_model
        )
      end

      def password_params
        params.require(:password).permit(:current_password, :new_password)
      end
    end
  end
end
