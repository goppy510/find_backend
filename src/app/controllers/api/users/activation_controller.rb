#frozen_string_literal: true

class Api::ActivationController < ApplicationController
  include SessionModule

  # 確認メールクリック後
  def activate
    token = header_token
    if token.blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = ActivationService.new(token)
    service.activate

    render json: { status: 'success' }, status: 200
  end
end
