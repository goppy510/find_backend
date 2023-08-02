# frozen_string_literal: true

module Api
  module Users
    class ProfileController < ApplicationController
      include SessionModule
      before_action :cookie_token?

      # プロフィール作成
      def create
        user_id = @auth[:user_id]
        ProfileService.create(user_id, profiles: profile_params.to_unsafe_h)

        render json: { status: 'success' }, status: :ok
      rescue StandardError
        raise ActionController::BadRequest
      end

      # ユーザー情報閲覧用
      def show
        if params[:token].blank?
          render_error(400, 'user', 'invalid_parameter')
          return
        end

        service = AccountService.new(params[:token])
        service.show
      end

      # パスワード更新用
      def update_password
        if params[:token].blank?
          render_error(400, 'user', 'invalid_parameter')
          return
        end

        service = AccountService.new(params[:token])
        service.update_password
      end

      # プロフィール更新用
      def update
        if params[:token].blank?
          render_error(400, 'user', 'invalid_parameter')
          return
        end

        user_service = AccountService.new(params[:token])
        user_service.update_profile
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
    end
  end
end
