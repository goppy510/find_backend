# frozen_string_literal: true

# ユーザーがアクティベーションメールのリンクをクリックしたらアカウントを有効化するためのもの
module Password
  class PasswordDomain
    include SessionModule
    include Password::PasswordError

    attr_reader :password

    def initialize(user_id, current_password, new_password)
      @user_id = user_id if user_id.present?
      @current_password = Account::Password.from_string(current_password) if current_password.present?
      @new_password = Account::Password.from_string(new_password) if new_password.present?

      freeze
    end

    def update
      UserRepository.update_password(@user_id, @current_password, @new_password)
    end

    class << self
      def update(user_id, current_password, new_password)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'current_passwordがありません' if current_password.blank?
        raise ArgumentError, 'new_passwordがありません' if new_password.blank?

        domain = new(user_id, current_password, new_password)
        domain&.update
      rescue Account::Password::PasswordFormatError => e
        Rails.logger.error(e)
        raise Password::PasswordError::PasswordFormatError
      rescue StandardError => e
        Rails.logger.error e
        raise e
      end
    end
  end
end
