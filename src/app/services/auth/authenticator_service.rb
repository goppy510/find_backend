#frozen_string_literal: true

require 'jwt'

class Auth::AuthenticatorService

  # トークンからcurrent_userを検索し、存在しない場合は401を返す
  def authenticate_user
    current_user.presence || unauthorized_user
  end

  # クッキーを削除する
  def delete_cookie
    return if cookies[token_access_key].blank?
    cookies.delete(token_access_key)
  end

  private

  # トークンの取得(リクエストヘッダー優先してなけばクッキーから取得）
  def token
    token_from_request_headers || cookies[token_access_key]
  end

  # リクエストヘッダーからトークンを取得する
  # フロント側でAuthorization = `Bearer ${<accessToken>}`というようにtokenを埋め込んでもらう前提
  def token_from_request_headers
    request.headers["Authorization"]&.split&.last
  end

  # クッキーのオブジェクトキー(config/initializers/user_auth.rb)
  def token_access_key
    Auth.token_access_key
  end

  # トークンのユーザーを返す
  def current_user
    return if token.blank?
    @_current_user ||= fetch_entity_from_token
  end

  # トークンからユーザーを取得する
  def fetch_entity_from_token
    Auth::AuthTokenService.new(token: token).entity_for_user
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError, JWT::EncodeError
    nil
  end

  # 401エラーかつ、クッキーを削除する
  def unauthorized_user
    head(:unauthorized) && delete_cookie
  end
end
