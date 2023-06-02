#frozen_string_literal: true

# tokenを取得した状態で、それを使った認証などをするクラス
class Auth::AuthenticatorService

  def initialize(header_token: nil, cookie_token: nil)
    @header_token = header_token if header_token.present?
    @cookie_token = cookie_token if cookie_token.present?
  end

  # トークンからcurrent_userを検索し、存在しない場合は401を返す
  def authenticate_user
    current_user
  end

  # トークンからcurrent_userを検索し、存在しない場合は401を返す
  def authenticate_user_not_activate
    current_not_activated_user
  end

  private

  # トークンのアクティベート済みのユーザーを返す（ログインチェック等で使う）
  def current_user
    return if token.blank?
    find_user_from_token
  end

  # トークンのアクティベート未のユーザーを返す（ログインチェック等で使う）
  def current_not_activated_user
    return if token.blank?
    find_not_activated_user_from_token
  end

  # トークンからアクティベート済みのユーザーを取得する
  def find_user_from_token
    service = Auth::AuthTokenService.new(token: token)
    return if service.payload[:type] != 'api'
    user = service&.find_available_user
    return unless user
    res = {
      exp: service.payload[:exp],
      user_id: user.id
    }
    res
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError, JWT::EncodeError => e
    nil
  end

  # トークンからアクティベート未のユーザーを取得する
  def find_not_activated_user_from_token
    service = Auth::AuthTokenService.new(token: token)
    return if service.payload[:type] != 'activation'
    user = service&.find_not_available_user
    return unless user
    res = {
      exp: service.payload[:exp],
      user_id: user.id
    }
    res
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError, JWT::EncodeError => e
    nil
  end

  # トークンの取得(リクエストヘッダー優先してなけばクッキーから取得）
  def token
    @header_token || @cookie_token
  end

  # クッキーのオブジェクトキー(config/initializers/user_auth.rb)
  def token_access_key
    Auth.token_access_key
  end
end
