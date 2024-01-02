# frozen_string_literal: true

class PasswordService
  class << self
    include SessionModule

    def update(token, current_password, new_password)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'current_passwordがありません' if current_password.blank?
      raise ArgumentError, 'new_passwordがありません' if new_password.blank?

      raise Password::PasswordError::Unauthorized unless authenticate_user(token)
      
      user_id = authenticate_user(token)[:user_id]
      Password::PasswordDomain.update(user_id, current_password, new_password)
    rescue StandardError => e
      Rails.logger.error e
      raise e
    end
  end
end
