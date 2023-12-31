# frozen_string_literal: true

module Api
  class PermissionsController < ApplicationController
    include SessionModule

    # 権限追加
    def create
      token = header_token
      target_user_id = params[:target_user_id]
      permissions = params[:permissions]
      raise ActionController::BadRequest if target_user_id.blank? || permissions.blank?

      PermissionService.create(token, target_user_id, permissions)
      render json: { status: 'success' }, status: :ok

    rescue Permissions::PermissionError::Forbidden => e
      Rails.logger.error e
      rescue403(e)
    rescue StandardError => e
      Rails.logger.error e
      raise ActionController::BadRequest
    end

    # 権限読み込み
    def show
      token = header_token
      target_user_id = params[:target_user_id]
      raise ActionController::BadRequest if target_user_id.blank?

      res = PermissionService.show(token, target_user_id)
      render json: res, status: :ok
    rescue Permissions::PermissionError::Forbidden => e
      Rails.logger.error e
      rescue403(e)
    rescue StandardError => e
      Rails.logger.error e
      raise ActionController::BadRequest
    end

    # 権限削除
    def destroy
      token = header_token
      target_user_id = params[:target_user_id]
      permissions = params[:permissions]
      raise ActionController::BadRequest if target_user_id.blank? || permissions.blank?

      PermissionService.destroy(token, target_user_id, permissions)
      render json: { status: 'success' }, status: :ok
    rescue Permissions::PermissionError::Forbidden => e
      Rails.logger.error e
      rescue403(e)
    rescue StandardError => e
      Rails.logger.error e
      raise ActionController::BadRequest
    end
  end
end
