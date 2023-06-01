#frozen_string_literal: true

class Api::Users::ActivationController < ApplicationController
  include SessionModule

  # 確認メールクリック後
  def activate
    token = header_token
    if token.blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    res = ActivationService.activate(token)

    render json: { status: 'success', message: 'activated' }, status: 200
  end
end
