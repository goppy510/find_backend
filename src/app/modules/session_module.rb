# frozen_string_literal: true

module SessionModule
  # tokenを生成する
  def generate_token(lifetime: nil, payload: {})
    Auth::AuthTokenService.new(lifetime:, payload:)
  end

  # トークンが有効ならUserオブジェクトを返す
  # ログイン後の処理はクッキーを使う
  # Service
  def authenticate_user(token)
    Auth::AuthenticatorService.new(cookie_token: token)&.authenticate_user
  end

  # アクティベート未のUserならオブジェクトを返す
  # アクティベート時はクッキーを生成しないのでヘッダーから取り出す
  # Service
  def authenticate_user_not_activate(token)
    Auth::AuthenticatorService.new(header_token: token)&.authenticate_user_not_activate
  end

  # クッキーを削除する（コントローラーで呼ばれる想定）
  def delete_cookie
    cookies.delete(Auth.token_access_key)
  end

  # クッキーから取り出す
  # Controller
  def cookie_token
    cookies[Auth.token_access_key]
  end

  # ヘッダーに含まれているトークンを取り出す
  # Controller
  def header_token
    request.headers['Authorization']&.split&.last
  end

  private

  # API認証用のトークン生成のためのペイロード
  def api_payload(user)
    {
      sub: user.id,
      type: 'api'
    }
  end

  # クッキーに保存するトークン
  def save_token_cookie(auth)
    {
      value: auth.token,
      expires: Time.zone.at(auth.payload[:exp]),
      secure: Rails.env.production?,
      http_only: true
    }
  end
end
