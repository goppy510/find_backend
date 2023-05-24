#frozen_string_literal: true

class Api::ActivationController < ApplicationController
  # 確認メールクリック後
  def activate
    if params[:token].blank?
      render_error(400, 'user', 'invalid_parameter')
      return
    end

    service = ActivationService.new(params[:token])
    response = service.activate

    render json: response
  end
end
