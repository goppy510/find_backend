# frozen_string_literal: true

module Signup
  class ContractSignupDomain
    include Signup::SignupError

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
      raise Signup::SignupError::DuplicateEntry
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e)
      raise e
    end

    class << self
      def signup(signups)
        raise ArgumentError, 'emailがありません' if signups[:signups][:email].blank?
        raise ArgumentError, 'passwordがありません' if signups[:signups][:password].blank?

        service = ContractSignupDomain.new(signups:)

        service&.add
        target_user = UserRepository.find_by_email(service.email)
        return if target_user.blank?

        ContractRepository.create(target_user.id)
        Rails.logger.info("Contract created_by: user_id: #{service.user_id}, target_user: #{target_user.id}")
      rescue Account::Email::EmailFormatError => e
        Rails.logger.error(e)
        raise Signup::SignupError::EmailFormatError
      rescue Account::Password::PasswordFormatError => e
        Rails.logger.error(e)
        raise Signup::SignupError::PasswordFormatError
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end
    end
  end
end
