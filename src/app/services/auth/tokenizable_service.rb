#frozen_string_literal: true

require 'jwt'

# Auth::AuthTokenServiceの上位
module Auth::TokenizableService

  def self.included(base)
    base.extend ClassMethods
  end

  # 有効期限付きのトークンを返す
  # メール本文やフロントに渡す「2時間以内に下記URLへアクセスしてください」のようなメッセージに埋め込むｔめのもの
  def to_lifetime_token(lifetime)
    auth = Auth::AuthTokenService.new(lifetime: lifetime, payload: { sub: id })
    { token: auth.token, lifetime_text: auth.lifetime_text }
  end
end
