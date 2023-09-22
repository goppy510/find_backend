# frozen_string_literal: true

module Api
  module Prompts
    class CategoryController < ApplicationController

      # カテゴリーリスト取得
      def index
        service = CategoryService.new
        response = service.show
        if response
          render json: response, status: :ok
          return
        end
        render_error(400, 'user', 'invalid_parameter')
      rescue StandardError => e
        Rails.logger.error e
        raise ActionController::BadRequest
      end
    end
  end
end
