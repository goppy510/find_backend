# frozen_string_literal: true

module Api
  module Users
    class UserController < ApplicationController
      include SessionModule

      def index
        token = header_token
        res = UsersService.index(token)
        if res.blank?
          render_error(404, 'user', 'not_found')
          return
        end

        render json: res, status: :ok
      rescue Members::UsersError::Forbidden => e
        rescue403(e)
      rescue StandardError => e
        rescue400(e)
      end

      def show
        raise ActionController::BadRequest if params[:user_id].blank?

        token = header_token
        res = UsersService.show(token, params[:user_id])
        if res.blank?
          render_error(404, 'contract', 'not_found')
          return
        end

        render json: res, status: :ok
      rescue Members::UsersError::Forbidden => e
        rescue403(e)
      rescue StandardError => e
        rescue400(e)
      end

      def destroy
        raise ActionController::BadRequest if params[:user_id].blank?

        token = header_token
        UsersService.destroy(token, params[:user_id])

        render json: { status: 'success' }, status: :ok
      rescue Members::UsersError::Forbidden => e
        rescue403(e)
      rescue StandardError => e
        rescue400(e)
      end
    end
  end
end
