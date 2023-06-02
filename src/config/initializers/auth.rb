#frozen_string_literal: true

module Auth
  mattr_accessor :token_signup_lifetime # アクティベーション用のtokenの有効期限のデフォルト
  mattr_accessor :token_lifetime # tokenの有効期限のデフォルト
  mattr_accessor :token_audience # クライアントを識別する文字
  mattr_accessor :token_signature_algorithm # 電子署名のアルゴリズム
  mattr_accessor :token_secret_signature_key # 電子署名に使う鍵
  mattr_accessor :token_public_key # 公開鍵
  mattr_accessor :token_access_key # Cookieに保存する際のオブジェクトキー
  mattr_accessor :not_found_exception_class # ユーザーが見つからない場合の例外

  self.token_signup_lifetime = 1.hour
  self.token_lifetime = 2.week
  self.token_audience = Settings[:app][:host]
  self.token_signature_algorithm = 'HS256'
  self.token_secret_signature_key = Rails.application.credentials.secret_key_base
  self.token_public_key = nil
  self.token_access_key = :access_token
  self.not_found_exception_class = ActiveRecord::RecordNotFound
end
