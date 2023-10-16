# frozen_string_literal: true

module Api
  module Users
    class SignupController < ApplicationController
      include SessionModule

      # 仮登録用
      def signup
        valid_params = { signups: signup_params.to_unsafe_h }
        SignupService.signup(valid_params)

        render json: { status: 'success' }, status: :ok

      rescue SignupService::DuplicateEntry => e
        rescue409(e)
      rescue SignupService::EmailFormatError => e
        rescue422(e)
      rescue SignupService::PasswordFormatError => e
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
