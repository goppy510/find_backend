# frozen_string_literal: true

class LoginService
  include SessionModule

  def initialize(email, password)
    @email = Account::Email.from_string(email)
    @password = Account::Password.from_string(password)
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
end
