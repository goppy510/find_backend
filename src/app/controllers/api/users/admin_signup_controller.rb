# frozen_string_literal: true

module Api
  module Users
    class AdminSignupController < ApplicationController
      include SessionModule

      # 仮登録用
      def signup
        token = header_token
        valid_params = { signups: signup_params.to_unsafe_h }
        AdminSignupService.signup(token, valid_params)

        render json: { status: 'success' }, status: :ok

      rescue AdminSignupService::DuplicateEntry => e
        rescue409(e)
      rescue AdminSignupService::EmailFormatError => e
        rescue422(e)
      rescue AdminSignupService::PasswordFormatError => e
        rescue422(e)
      rescue StandardError => e
        rescue400(e)
      end

      private

      def signup_params
        params.require(:signups).permit(:email, :password)
      end
    end
  end
end
