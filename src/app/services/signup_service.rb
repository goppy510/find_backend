# frozen_string_literal: true

class SignupService
  include SessionModule

  class DuplicateEntry < StandardError; end
  class EmailFormatError < StandardError; end
  class PasswordFormatError < StandardError; end

  attr_reader :email,
              :password,
              :user_id,
              :expires_at

  def initialize(signups: nil)
    hash_signups = signups[:signups] if signups.present?

    @email = Account::Email.from_string(hash_signups[:email]) if hash_signups&.key?(:email)
    @password = Account::Password.from_string(hash_signups[:password]) if hash_signups&.key?(:password)

    freeze
  end

  # ユーザー情報をDBに登録する
  def add
    UserRepository.create(@email, @password)
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.error(e)
    raise DuplicateEntry
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e)
    raise e
  end

  private

  class << self
    def signup(signups)
      raise ArgumentError, 'emailがありません' if signups[:signups][:email].blank?
      raise ArgumentError, 'passwordがありません' if signups[:signups][:password].blank?

      service = SignupService.new(signups:)
      service&.add

      ActivationMailService.activation_email(service.email)
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
