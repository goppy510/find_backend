#frozen_string_literal: true

class SignupService
  attr_reader :email, :password, :token, :expires_at

  def initialize(email, password)
    raise ArgumentError, 'emailがありません' unless email
    raise ArgumentError, 'passwordがありません' unless password

    @email = Email.from_string(email)
    @password = Password.from_string(password)
    @token = Registration.token
    @expires_at = Registration.expires_at

    self.freeze
  end

  # ユーザー情報をDBに登録する
  def signup
    ActiveRecord::Base.transaction do
      User.create!(email: self.email.to_s, password: self.password.to_s)
      RegistrationToken.create!(user_id: user.id, token: self.token.to_s, expires_at: self.expires_at.to_s)
    end
  rescue ActiveRecord::RecordInvalid => e
    raise SignupError, e.message
  end

  # 本登録用のメールを送信する
  def send_activation_email
    user = User.find_by(email: self.email.to_s)
    registration_token = RegistrationToken.find_by(user_id: user.id)

    raise RecordNotFound, 'userまたはregistration_tokenがありません' if user.blank? || if registration_token.blank?

    # メールの作成と送信
    RegsitrationMailer.send_registration_mail(self.email.to_s, self.token.to_s, self.expires_at.to_s).deliver
  end
end

class SignupError < StandardError; end
class SubmitVerifyEmailError < StandardError; end
