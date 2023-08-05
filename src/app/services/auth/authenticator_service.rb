# frozen_string_literal: true

# tokenを取得した状態で、それを使った認証などをするクラス
module Auth
  class AuthenticatorService
    def initialize(header_token: nil, cookie_token: nil)
      @header_token = header_token if header_token.present?
      @cookie_token = cookie_token if cookie_token.present?
    end

    # トークンからcurrent_userを検索し、存在しない場合は401を返す
    def authenticate_user
      find_user_from_token
    end

    # トークンからcurrent_userを検索し、存在しない場合は401を返す
    def authenticate_user_not_activate
      return if token.blank?

      find_not_activated_user_from_token
    end

    private

    # トークンの取得(リクエストヘッダー優先してなけばクッキーから取得）
    def token
      @header_token || @cookie_token
    end

    # トークンからアクティベート済みのユーザーを取得する
    def find_user_from_token
      service = Auth::AuthTokenService.new(token:)
      return if service.payload[:type] != 'api'

      user = service&.find_available_user
      return unless user

      {
        exp: service.payload[:exp],
        user_id: user.id
      }
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError, JWT::EncodeError
      nil
    end

    # トークンからアクティベート未のユーザーを取得する
    def find_not_activated_user_from_token
      service = Auth::AuthTokenService.new(token:)
      return if service.payload[:type] != 'activation'

      user = service&.find_not_available_user
      return unless user

      {
        exp: service.payload[:exp],
        user_id: user.id
      }
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError, JWT::EncodeError
      nil
    end

    # クッキーのオブジェクトキー(config/initializers/user_auth.rb)
    def token_access_key
      Auth.token_access_key
    end
  end
end
