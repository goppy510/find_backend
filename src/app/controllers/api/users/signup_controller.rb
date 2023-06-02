#frozen_string_literal: true

class Api::Users::SignupController < ApplicationController
  include SessionModule

  # 仮登録用
  def signup
    if signup_params[:email].blank? || signup_params[:password].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    SignupService.signup(signup_params[:email], signup_params[:password])

    render json: { status: 'success' }, status: 200
  end

  private

  def signup_params
    params.permit(:email, :password)
  end
end
