#frozen_string_literal: true

module UserAuth
  # 必須
  mattr_accessor :token_lifetime
  self.token_lifetime = 2.week

  mattr_accessor :token_audience
  self.token_audience = -> {
    Settings[:app][:host]
  }

  mattr_accessor :token_signature_algorithm
  self.token_signature_algorithm = "HS256"

  mattr_accessor :token_secret_signature_key
  self.token_secret_signature_key = -> {
    Rails.application.credentials.secret_key_base
  }

  mattr_accessor :token_public_key
  self.token_public_key = nil

  mattr_accessor :token_access_key
  self.token_access_key = :access_token

  mattr_accessor :not_found_exception_class
  self.not_found_exception_class = ActiveRecord::RecordNotFound

  def decode_key
    UserAuth.token_public_key || secret_key
  end

  def algorithm
    UserAuth.token_signature_algorithm
  end

  # オーディエンスの値がある場合にtrueを返す
  def verify_audience?
    UserAuth.token_audience.present?
  end

  def token_audience
    verify_audience? && UserAuth.token_audience.call
  end

  # トークン有効期限を秒数で返す
  def token_lifetime
    @lifetime.from_now.to_i
  end

  def decode_options
    {
      aud: token_audience,
      verify_aud: verify_audience?,
      algorithm: algorithm
    }
  end

  def claims
    _claims = {}
    _claims[:exp] = token_lifetime
    _claims[:aud] = token_audience if verify_audience?
    _claims
  end

  def header_fields
    { typ: "JWT" }
  end
end
