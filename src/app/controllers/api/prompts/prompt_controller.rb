# frozen_string_literal: true

module Api
  module Prompts
    class PromptController < ApplicationController
      include SessionModule

      # プロンプト一覧を表示する
      def index
        raise ActionController::BadRequest if params[:page].blank?

        res = PromptService.prompt_list(params[:page])
        render json: res, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # プロンプト作成
      def create
        token = header_token
        valid_prompts = { prompts: prompt_params.to_unsafe_h }
        prompt_uuid = PromptService.create(token, valid_prompts)
        render json: { status: 'success', prompt_uuid: }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # プロンプトの詳細を表示する
      def show
        token = header_token
        raise ActionController::BadRequest if params[:uuid].blank?

        res = PromptService.show(token, params[:uuid])
        render json: res, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # プロンプトを更新する
      def update
        token = header_token
        raise ActionController::BadRequest if params[:uuid].blank?

        PromptService.update(token, params[:uuid], prompts: params[:prompts])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # プロンプトを削除する
      def delete
        token = header_token
        raise ActionController::BadRequest if params[:uuid].blank?

        PromptService.delete(token, params[:uuid])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # いいね
      def like
        token = header_token
        PromptService.like(token, params[:prompt_id])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # いいね解除
      def dislike
        token = header_token
        PromptService.dislike(token, params[:prompt_id])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # ブックマーク
      def bookmark
        token = header_token
        PromptService.bookmark(token, params[:prompt_id])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      # ブックマーク解除
      def disbookmark
        token = header_token
        PromptService.disbookmark(token, params[:prompt_id])
        render json: { status: 'success' }, status: :ok
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end

      private

      def prompt_params
        params.require(:prompts).permit(
          :about,
          :title,
          :input_example,
          :output_example,
          :prompt,
          :category_id,
          :generative_ai_model_id
        )
      end
    end
  end
end
