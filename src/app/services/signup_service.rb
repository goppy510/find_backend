#frozen_string_literal: true

class SignupService
  attr_reader :email, :password, :token, :expires_at

  def initialize(email, password)
    raise ArgumentError, 'emailまたはpasswordがありません' if email.blank? or password.blank?

    @email = Account::Email.from_string(email)
    @password = Account::Password.from_string(password)
    @token = Account::Registration.token
    @expires_at = Account::Registration.expires_at

    self.freeze
  end

  # ユーザー情報をDBに登録する
  def signup
    ActiveRecord::Base.transaction do
      user = UserRepository.create(@email, @password)
      RegistrationTokenRepository.create(user.id, @token, @expires_at)
    end
  rescue ActiveRecord::RecordInvalid => e
    raise SignupError, e.message
  end

  # 本登録用のメールを送信する
  def activation_email
    user = UserUserRepository.find_by_email(@email)
    registration_token = RegistrationTokenRepository.find_by_user_id(user.id)

    raise RecordNotFound, 'userまたはregistration_tokenがありません' if user.blank? || registration_token.blank?

    # メールの作成と送信
    RegistrationMailer.send_activation_mail(@email, @token, @expires_at).deliver
  end
end

class SignupError < StandardError; end
class SubmitVerifyEmailError < StandardError; end
