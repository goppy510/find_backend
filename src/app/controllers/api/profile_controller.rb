# frozen_string_literal: true

class Api
  class ProfileController < ApplicationController
    include SessionModule
    before_action :authenticate_user

    # プロフィール作成
    def create
      token = cookie_token
      AccountService.create(token, profile_params)
    end

    # ユーザー情報閲覧用
    def show
      if params[:token].blank?
        render_error(400, 'user', 'invalid_parameter')
        return
      end

      service = AccountService.new(params[:token])
      service.show
    end

    # パスワード更新用
    def update_password
      if params[:token].blank?
        render_error(400, 'user', 'invalid_parameter')
        return
      end

      service = AccountService.new(params[:token])
      service.update_password
    end

    # プロフィール更新用
    def update
      if params[:token].blank?
        render_error(400, 'user', 'invalid_parameter')
        return
      end

      user_service = AccountService.new(params[:token])
      user_service.update_profile
    end

    private

    def profile_params
      params.require(:profile).permit(
        :name,
        :phone_number,
        :company_name,
        :employee_count,
        :industry,
        :position,
        :business_model,
        :token
      )
    end
  end
end
