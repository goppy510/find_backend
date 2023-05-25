class ApplicationController < ActionController::Base
  include ActionController::Cookies
  include UserAuth::Authenticator

  protect_from_forgery with: :null_session
  before_action :authenticate_token
  rescue_from StandardError, with: :render_500
  rescue_from ActiveRecord::RecordInvalid, with: :render_422
  rescue_from AuthenticationError, with: :not_authenticated

  extend T::Sig

  # エラーをjsonで返すメソッド
  sig { params(status: Integer, resource: String, code: String).void }
  def render_error(status = 400, resource, code)
    message = I18n.t("errors.#{resource}.#{code}")
    render json: { error: { status: status, code: code,  message: message }, status: status
  end

  def current_user
    @current_user ||= Jwt::UserAuthenticator.call(request.headers)
  end

  def authenticate
    raise AuthenticationError unless current_user
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
