# frozen_string_literal: true

module Api
  module Users
    class LoginController < ApplicationController
      include SessionModule

      # ログイン
      def create
        if login_params[:email].blank? || login_params[:password].blank?
          render_error(400, 'user', 'invalid_parameter')
          return
        end

        service = LoginService.new(login_params[:email], login_params[:password])
        res = service.login
        if res
          cookies.encrypted[Auth.token_access_key] = res[:cookie]
          render json: { status: 'success', data: res[:response] }, status: :ok
          return
        end
        render_error(400, 'user', 'invalid_parameter')
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # ログアウト
      def destroy
        delete_cookie
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      private

      def login_params
        params.permit(:email, :password)
      end
    end
  end
end
