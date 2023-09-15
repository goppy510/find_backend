# frozen_string_literal: true

module Api
  module Users
    class ProfileController < ApplicationController
      include SessionModule

      # プロフィール作成
      def create
        token = header_token
        valid_profiles = { profiles: profile_params.to_unsafe_h }
        ProfileService.create(token, valid_profiles)
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # プロフィール更新用
      def update
        token = header_token
        ProfileService.update_profiles(token, profiles: params[:profiles])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # パスワード更新用
      def update_password
        token = header_token
        ProfileService.update_password(token, password_params[:current_password], password_params[:new_password])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # ユーザー情報閲覧用
      def show
        token = header_token
        res = ProfileService.show(token)
        render json: res, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      private

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
