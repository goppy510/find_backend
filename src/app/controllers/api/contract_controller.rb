# frozen_string_literal: true

module Api
  class ContractController < ApplicationController
    include SessionModule

    # 権限追加
    def create
      token = header_token
      target_user_id = params[:user_id]
      max_member_count = params[:max_member_count]
      raise ActionController::BadRequest if target_user_id.blank? || max_member_count.blank?

      ContractService.create(token, target_user_id, max_member_count)
      render json: { status: 'success' }, status: :ok

    rescue Contracts::ContractsError::Forbidden => e
      Rails.logger.error e
      rescue403(e)
    rescue StandardError => e
      Rails.logger.error e
      raise ActionController::BadRequest
    end

    # 権限読み込み
    def show
      token = header_token
      target_user_id = params[:user_id]
      raise ActionController::BadRequest if target_user_id.blank?

      res = ContractService.show(token, target_user_id)
      render json: res, status: :ok
    rescue Contracts::ContractsError::Forbidden => e
      Rails.logger.error e
      rescue403(e)
    rescue StandardError => e
      Rails.logger.error e
      raise ActionController::BadRequest
    end

    def index
      token = header_token
      res = ContractService.index(token)
      render json: res, status: :ok
    rescue Contracts::ContractsError::Forbidden => e
      Rails.logger.error e
      rescue403(e)
    rescue StandardError => e
      Rails.logger.error e
      raise ActionController::BadRequest
    end

    def update
      token = header_token
      target_user_id = params[:user_id]
      max_member_count = params[:max_member_count]
      raise ActionController::BadRequest if target_user_id.blank? || max_member_count.blank?

      ContractService.update(token, target_user_id, max_member_count)
      render json: { status: 'success' }, status: :ok
    rescue Contracts::ContractsError::Forbidden => e
      Rails.logger.error e
      rescue403(e)
    rescue StandardError => e
      Rails.logger.error e
      raise ActionController::BadRequest
    end

    # 権限削除
    def destroy
      token = header_token
      target_user_id = params[:user_id]
      raise ActionController::BadRequest if target_user_id.blank?

      ContractService.destroy(token, target_user_id)
      render json: { status: 'success' }, status: :ok
    rescue Contracts::ContractsError::Forbidden => e
      Rails.logger.error e
      rescue403(e)
    rescue StandardError => e
      Rails.logger.error e
      raise ActionController::BadRequest
    end
  end
end
