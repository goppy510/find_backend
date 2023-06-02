#frozen_string_literal: true

module ErrorHandlers
  extend ActiveSupport::Concern

  include do
    rescue_from ActionController::AuthenticationError, with: :rescue401
    rescue_from ActionController::BadRequest, with: :rescue400
    rescue_from ActionController::Unauthorized, with: :rescue401
    rescue_from ActionController::Forbidden, with: :rescue403
    rescue_from ActionController::RecordNotFound, with: :rescue404
  end

  private

  def rescue400(e)
    @exception = e
    render json: { error: { status: 400, code: e.message, message: I18n.t("errors.code.#{e.message}") } }, status: :bad_request
  end

  def rescue401(e)
    @exception = e
    render json: { error: { status: 401, code: e.message, message: I18n.t("errors.code.#{e.message}") } }, status: :unauthorized
  end

  def rescue403(e)
    @exception = e
    render json: { error: { status: 403, code: e.message, message: I18n.t("errors.code.#{e.message}") } }, status: :forbidden
  end

  def rescue404(e)
    @exception = e
    render json: { error: { status: 404, code: e.message, message: I18n.t("errors.code.#{e.message}") } }, status: :not_found
  end
end
