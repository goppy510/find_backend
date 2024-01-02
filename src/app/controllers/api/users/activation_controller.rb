# frozen_string_literal: true

module Api
  module Users
    class ActivationController < ApplicationController
      include SessionModule

      # 確認メールクリック後
      def create
        token = header_token
        if token.blank?
          render_error(400, 'user', 'invalid_parameter')
          return
        end

        ActivationService.activate(token)

        render json: { status: 'success', message: 'activated' }, status: :ok
      rescue Activation::ActivationError::Unauthorized => e
        Rails.logger.error e
        raise ActionController::Unauthorized
      end
    end
  end
end
