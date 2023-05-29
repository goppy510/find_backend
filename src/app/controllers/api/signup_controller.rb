#frozen_string_literal: true

class Api::SignupController < ApplicationController
  include SessionModule

  # 仮登録用
  def signup
    if signup_params[:email].blank? || signup_params[:password].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = SignupService.new(signup_params[:email], signup_params[:password])
    service.signup
    service.activation_email

    render json: { status: 'success' }, status: 200
  end

  private

  def signup_params
    params.permit(:email, :password)
  end
end
