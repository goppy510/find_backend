#frozen_string_literal: true

require 'jwt'

module Auth::TokenizableService

  def self.included(base)
    base.extend ClassMethods
  end

  ## instance method
  # トークンを返す
  def to_token
    AuthTokenService.new(payload: to_token_payload).token
  end

  # 有効期限付きのトークンを返す
  def to_lifetime_token(lifetime)
    auth = AuthTokenService.new(lifetime: lifetime, payload: to_token_payload)
    { token: auth.token, lifetime_text: auth.lifetime_text }
  end

  private

  def to_token_payload
    { sub: id }
  end

  ## class method
  module ClassMethods
    # 追加
    def from_token(token)
      auth_token = AuthTokenService.new(token: token)
      from_token_payload(auth_token.payload)
    end

    private

    def from_token_payload(payload)
      find(payload["sub"])
    end
  end
end
