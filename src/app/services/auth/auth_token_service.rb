#frozen_string_literal: true

require 'jwt'

class Auth::AuthTokenService
  attr_reader :token
  attr_reader :payload # tokenに埋め込む情報
  attr_reader :lifetime # tokenの追加オプション

  def initialize(lifetime: nil, payload: {}, token: nil, options: {})
    if token.present?
      @payload, _ = JWT.decode(token.to_s, decode_key, true, decode_options.merge(options))
      @payload = @payload.transform_keys(&:to_sym) #tokenがある場合はclaimsによってkeyがシンボルになるので合わせた
      @token = token
      return
    end
    @lifetime = lifetime || Auth.token_lifetime
    @payload = claims.merge(payload)
    @token = JWT.encode(@payload, secret_key, algorithm, header_fields)
  end

  # subjectからアクティベート済みのユーザーを検索する
  def find_available_user
    # subのvalueにuser.idが入っている
    user = UserRepository.find_by_id(@payload[:sub])
    return user if user&.activated
  end

  # subjectからアクティベート未のユーザーを検索する
  def find_not_available_user
    user = UserRepository.find_by_id(@payload[:sub])
    return user if user&.activated == false
  end

  # token_lifetimeの日本語変換を返す
  def lifetime_text
    time, period = @lifetime.inspect.sub(/s\z/,"").split
    time + I18n.t("datetime.periods.#{period}", default: "")
  end

  private

  # エンコードキー
  # config/initializers/auth.rb　で定義
  def secret_key
    Auth.token_secret_signature_key
  end

  # デコードキー
  # config/initializers/auth.rb　で定義
  def decode_key
    Auth.token_public_key || secret_key
  end

  # トークン有効期限を秒数で返す
  def token_lifetime
    @lifetime.from_now.to_i
  end

  # デコード時オプション
  # verify_audがtrueのとき、encode時のaud === decode時のaudでないと無効なtokenとみなす
  def decode_options
    {
      aud: token_audience,
      verify_aud: verify_audience?,
      algorithm: algorithm
    }
  end

  # オーディエンス
  def token_audience
    verify_audience? && Auth.token_audience
  end

  # オーディエンスの値がある場合にtrueを返す
  def verify_audience?
    Auth.token_audience.present?
  end

  # アルゴリズム
  # config/initializers/auth.rb　で定義
  def algorithm
    Auth.token_signature_algorithm
  end

  # クレーム
  # payloadに含める値のこと
  def claims
    _claims = {}
    _claims[:exp] = token_lifetime
    _claims[:aud] = token_audience if verify_audience?
    _claims
  end

  # encode時のヘッダー
  def header_fields
    { type: "JWT" }
  end
end
