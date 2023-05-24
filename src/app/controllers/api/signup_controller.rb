#frozen_string_literal: true

class Api::SignupController < ApplicationController
  # 仮登録用
  def signup
    if params[:email].blank? || params[:password].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = SignupService.new(params[:email], params[:password])
    service.signup
    service.activation_email

    render json: { status: 'success' }, status: 200
  end
end
