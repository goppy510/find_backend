# frozen_string_literal: true

module Api
  module Users
    class SignupController < ApplicationController
      include SessionModule

      # 仮登録用
      def create
        token = header_token
        valid_params = { signups: signup_params.to_unsafe_h }
        SignupService.signup(token, valid_params)

        render json: { status: 'success' }, status: :ok

      rescue Signup::SignupError::DuplicateEntry => e
        rescue409(e)
      rescue Signup::SignupError::EmailFormatError, Signup::SignupError::PasswordFormatError => e
        rescue422(e)
      rescue Signup::SignupError::RecordLimitExceeded, Signup::SignupError::Forbidden => e
        rescue403(e)
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
