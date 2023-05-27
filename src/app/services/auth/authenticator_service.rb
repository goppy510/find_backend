#frozen_string_literal: true

require 'jwt'

# tokenを取得した状態で、それを使った認証などをするクラス
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

  # トークンのユーザーを返す
  def current_user
    return if token.blank?
    @_current_user ||= find_user_from_token
  end

  # トークンからユーザーを取得する
  def find_user_from_token
    service = Auth::AuthTokenService.new(token: token)
    user = service.find_available_user
    res = {
      exp: service.payload[:exp],
      user_id: user.id
    }
    res
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError, JWT::EncodeError => e
    raise e
  end

  # トークンの取得(リクエストヘッダー優先してなけばクッキーから取得）
  def token
    token_from_request_headers || token_from_cookies
  end

  def token_from_cookies
    cookies[token_access_key]
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

  # 401エラーかつ、クッキーを削除する
  def unauthorized_user
    head(:unauthorized) && delete_cookie
  end
end
