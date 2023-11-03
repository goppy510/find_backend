# frozen_string_literal: true

module Api
  module Users
    class PasswordController < ApplicationController
      include SessionModule

      def update
        token = header_token
        PasswordService.update(token, password_params[:current_password], password_params[:new_password])

        render json: { status: 'success' }, status: :ok

      rescue Password::PasswordError::Unauthorized => e
        rescue401(e)
      rescue StandardError => e
        rescue400(e)
      end

      private

      def password_params
        params.require(:password).permit(:current_password, :new_password)
      end
    end
  end
end
