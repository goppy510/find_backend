# frozen_string_literal: true

class LoginService
  include SessionModule

  class EmailFormatError < StandardError; end
  class PasswordFormatError < StandardError; end

  attr_reader :email, :password

  def initialize(logins: nil)
    hash_logins = logins[:logins] if logins.present?

    @email = Account::Email.from_string(hash_logins[:email]) if hash_logins&.key?(:email)
    @password = Account::Password.from_string(hash_logins[:password]) if hash_logins&.key?(:password)
  end

  # ログイン
  def login
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
    def login(logins)
      raise ArgumentError, 'emailがありません' if logins[:logins][:email].blank?
      raise ArgumentError, 'passwordがありません' if logins[:logins][:password].blank?

      service = LoginService.new(logins:)
      service&.login

    rescue Account::Email::EmailFormatError => e
      Rails.logger.error(e)
      raise EmailFormatError
    rescue Account::Password::PasswordFormatError => e
      Rails.logger.error(e)
      raise PasswordFormatError
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end
  end
end
