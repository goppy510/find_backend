# frozen_string_literal: true

module SessionModule
  # tokenを生成する
  def generate_token(lifetime: nil, payload: {})
    Auth::AuthTokenService.new(lifetime:, payload:)
  end

  # トークンが有効ならUserオブジェクトを返す
  # ログイン後の処理はクッキーを使う
  def authenticate_user(token)
    @auth = Auth::AuthenticatorService.new(cookie_token: token)&.authenticate_user
  end

  # アクティベート未のUserならオブジェクトを返す
  # アクティベート時はクッキーを生成しないのでヘッダーから取り出す
  def authenticate_user_not_activate(token)
    @auth = Auth::AuthenticatorService.new(header_token: token)&.authenticate_user_not_activate
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
end
