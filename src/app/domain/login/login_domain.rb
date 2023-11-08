# frozen_string_literal: true

module Login
  class LoginDomain
    include SessionModule
    include Login::LoginError

    attr_reader :email, :password

    def initialize(logins: nil)
      hash_logins = logins[:logins] if logins.present?

      @email = Account::Email.from_string(hash_logins[:email]) if hash_logins&.key?(:email)
      @password = Account::Password.from_string(hash_logins[:password]) if hash_logins&.key?(:password)
    end

    # ログイン
    def create
      activated_user = UserRepository.find_by_activated(@email, @password)
      return unless activated_user

      # api認証用のtokenを生成する
      payload = api_payload(activated_user)
      auth = generate_token(payload:)

      {
        token: auth.token,
        expires: Time.zone.at(auth.payload[:exp])
      }
    end

    class << self
      def create(logins)
        raise ArgumentError, 'emailがありません' if logins[:logins][:email].blank?
        raise ArgumentError, 'passwordがありません' if logins[:logins][:password].blank?

        domain = new(logins:)
        domain&.create

      rescue Account::Email::EmailFormatError => e
        Rails.logger.error(e)
        raise Login::LoginError::EmailFormatError
      rescue Account::Password::PasswordFormatError => e
        Rails.logger.error(e)
        raise Login::LoginError::PasswordFormatError
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end
    end
  end
end
