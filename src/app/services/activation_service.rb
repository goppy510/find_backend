#frozen_string_literal: true

class ActivationService

  def initialize(token)
    raise ArgumentError, 'tokenがありません' unless token
    user = find_by_token(token)
    raise ActiveRecord::RecordNotFound, 'userが見つかりません' unless user
    @user = user

    freeze
  end

  # activate
  def activate
    ActiveRecord::Base.transaction do
      @user.update!(confirmed: true)
      RegistrationToken.find_by(user_id: @user.id)&.destroy!
    end
  end

  private

  def find_by_token(token)
    registration_token = RegistrationToken.find_by(token: token)
    raise ActiveRecord::RecordNotFound, 'registration_tokenがありません' if registration_token.blank?
    raise ExpiredTokenError, 'tokenの有効期限が切れています' if registration_token.expires_at < Time.current
    registration_token.user
  end
end

class ExpiredTokenError < StandardError; end
class TokenNotFound < StandardError; end
