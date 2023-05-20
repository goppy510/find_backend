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

  def signup
    user = nil
    registration = nil

    ActiveRecord::Base.transaction do
      user = User.create!(email: self.email.to_s, password: self.password.to_s)
      registration = RegistrationToken.create!(user_id: user.id, token: self.token.to_s, expires_at: self.expires_at.to_s)
    end
    result = {}
    if user.present? && registration.present?
      result[:email] = user.email
      result[:token] = registration.token
    end
    result
  rescue ActiveRecord::RecordInvalid => e
    raise SignupError, e.message
  end
end

class SignupError < StandardError; end
