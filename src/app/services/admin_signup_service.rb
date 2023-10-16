# frozen_string_literal: true

class AdminSignupService
  include SessionModule

  class DuplicateEntry < StandardError; end
  class EmailFormatError < StandardError; end
  class PasswordFormatError < StandardError; end
  class Forbidden < StandardError; end

  attr_reader :email,
              :password,
              :user_id,
              :expires_at

  def initialize(signups: nil, token: nil)
    hash_signups = signups[:signups] if signups.present?
    hash_token = token[:token] if token.present?
    @user_id = authenticate_user(hash_token)[:user_id] if hash_token.present?

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

  class << self
    def signup(signups, token)
      raise ArgumentError, 'emailがありません' if signups[:signups][:email].blank?
      raise ArgumentError, 'passwordがありません' if signups[:signups][:password].blank?
      raise ArgumentError, 'tokenがありません' if token[:token].blank?

      service = AdminSignupService.new(signups:, token:)

      # contract権限がなければ登録させない
      raise Forbidden if !PermissionService.has_contract_role?(token[:token])

      service&.add
      target_user = UserRepository.find_by_email(service.email)
      return if target_user.blank?

      ContractRepository.create(target_user.id)
      Rails.logger.info("Contract created_by: user_id: #{service.user_id}, target_user: #{target_user.id}")
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
