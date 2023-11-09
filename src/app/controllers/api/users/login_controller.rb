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

        response = LoginService.create(logins: login_params)
        if response
          render json: response, status: :ok
          return
        end
        render_error(400, 'user', 'invalid_parameter')
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      private

      def login_params
        params.require(:logins).permit(:email, :password)
      end
    end
  end
end
