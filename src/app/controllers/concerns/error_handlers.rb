# frozen_string_literal: true

require_dependency 'signup_service'

module ErrorHandlers
  extend ActiveSupport::Concern

  included do
    rescue_from SignupService::DuplicateEntry, with: :rescue409
    rescue_from SignupService::EmailFormatError, with: :rescue422
    rescue_from SignupService::PasswordFormatError, with: :rescue422
    rescue_from ActionController::BadRequest, with: :rescue400
    rescue_from ActionController::Unauthorized, with: :rescue401
    rescue_from ActionController::Forbidden, with: :rescue403
    rescue_from ActiveRecord::RecordNotFound, with: :rescue404
  end

  private

  def rescue400(err)
    @exception = err
    render json: {
      error: {
        status: 400,
        code: err.message,
        message: I18n.t("errors.coderr.#{err.message}")
      }
    }, status: :bad_request
  end

  def rescue401(err)
    @exception = err
    render json: {
      error: {
        status: 401, code: err.message, message: I18n.t("errors.coderr.#{err.message}")
      }
    }, status: :unauthorized
  end

  def rescue403(err)
    @exception = err
    render json: {
      error: {
        status: 403, code: err.message, message: I18n.t("errors.coderr.#{err.message}")
      }
    }, status: :forbidden
  end

  def rescue404(err)
    @exception = err
    render json: {
      error: {
        status: 404, code: err.message, message: I18n.t("errors.coderr.#{err.message}")
      }
    }, status: :not_found
  end

  def rescue409(err)
    @exception = err
    render json: {
      error: {
        status: 409, code: err.message, message: I18n.t("errors.coderr.#{err.message}")
      }
    }, status: :conflict
  end

  def rescue422(err)
    @exception = err
    render json: {
      error: {
        status: 422, code: err.message, message: I18n.t("errors.coderr.#{err.message}")
      }
    }, status: :unprocessable_entity
  end
end
