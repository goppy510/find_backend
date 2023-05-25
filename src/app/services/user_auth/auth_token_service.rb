#frozen_string_literal: true

require 'jwt'

module UserAuth
  class AuthTokenService
    attr_reader :token, :payload, :lifetime

    def initialize(lifetime: nil, payload: {}, token: nil, options: {})
      if token.present?
        @payload, _ = JWT.decode(token.to_s, decode_key, true, decode_options.merge(options))
        @token = token
        return
      end
      @lifetime = lifetime || UserAuth.token_lifetime
      @payload = claims.merge(payload)
      @token = JWT.encode(@payload, secret_key, algorithm, header_fields)
    end

    # subjectからユーザーを検索する
    def entity_for_user
      User.find @payload["sub"]
    end

    # token_lifetimeの日本語変換を返す
    def lifetime_text
      time, period = @lifetime.inspect.sub(/s\z/,"").split
      time + I18n.t("datetime.periods.#{period}", default: "")
    end

    private

    # エンコードキー(config/initializers/user_auth.rb)
    def secret_key
      UserAuth.token_secret_signature_key.call
    end

    # デコードキー(config/initializers/user_auth.rb)
    def decode_key
      UserAuth.token_public_key || secret_key
    end
  end
end
