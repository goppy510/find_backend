# frozen_string_literal: true

module Api
  module Users
    class PermissionController < ApplicationController
      include SessionModule

      # 権限追加
      def create
        token = header_token
        valid_params = { permissions: permission_params.to_unsafe_h }
        PermissionService.create(token, valid_params)
        render json: { status: 'success' }, status: :ok

      rescue PermissionService::Forbidden => e
        Rails.logger.error e
        rescue403(e)
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # 権限読み込み
      def show
        token = header_token
        valid_params = { permissions: show_params.to_unsafe_h }
        res = PermissionService.show(token, valid_params)
        render json: res, status: :ok
      rescue PermissionService::Forbidden => e
        Rails.logger.error e
        rescue403(e)
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # 権限削除
      def delete
        token = header_token
        valid_params = { permissions: permission_params.to_unsafe_h }
        PermissionService.delete(token, valid_params)
        render json: { status: 'success' }, status: :ok
      rescue PermissionService::Forbidden => e
        Rails.logger.error e
        rescue403(e)
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      private

      def permission_params
        params.require(:permissions).permit(
          :target_user_id,
          :resource
        )
      end

      def show_params
        params.require(:permissions).permit(
          :target_user_id
        )
      end
    end
  end
end
