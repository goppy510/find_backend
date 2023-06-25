# frozen_string_literal: true

module Api
  module Users
    class SignupController < ApplicationController
      include SessionModule

      # 仮登録用
      def signup
        if signup_params[:email].blank? || signup_params[:password].blank?
          render_error(400, 'user', 'invalid_parameter')
          return
        end

        SignupService.signup(signup_params[:email], signup_params[:password])

        render json: { status: 'success' }, status: :ok
      end

      private

      def signup_params
        params.permit(:email, :password)
      end
    end
  end
end
