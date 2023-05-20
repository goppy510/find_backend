#frozen_string_literal: true

class SignupService
  attr_reader :email, :password

  def initialize(email, password)
    raise ArgumentError, 'emailがありません' unless email
    raise ArgumentError, 'passwordがありません' unless password

    @email = Email.from_string(email)
    @password = Password.from_string(password)

    self.freeze
  end

  class << self
    def signup(email, password)
      service = self.new(email, password)
      User.create(email: service.email.value, password: service.password.value)
    rescue ActiveRecord::RecordInvalid => e
      raise InvalidUserError, e.message
    end
  end
end

class InvalidUserError < StandardError; end
