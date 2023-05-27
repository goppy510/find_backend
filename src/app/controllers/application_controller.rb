class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  include ActionController::Cookies
  include Auth::AuthenticatorService

  before_action :authenticate_token
  rescue_from StandardError, with: :render_500
  rescue_from ActiveRecord::RecordInvalid, with: :render_422
  rescue_from AuthenticationError, with: :not_authenticated

  # エラーをjsonで返すメソッド
  def render_error(status = 400, resource, code)
    message = I18n.t("errors.#{resource}.#{code}")
    render json: { error: { status: status, code: code,  message: message }, status: status
  end

  private

  def render_500(error)
    # エラーハンドリングの処理
    # レスポンスの設定などを行う
    render json: { error: error.message }, status: :internal_server_error
  end

  def render_422(exception)
    render json: { error: { messages: exception.record.errors.full_messages } }, status: :unprocessable_entity
  end

  def not_authenticated
    render json: { error: { messages: 'ログインしてください' } }, status: :unauthorized
  end
end

class AuthenticationError < StandardError; end
