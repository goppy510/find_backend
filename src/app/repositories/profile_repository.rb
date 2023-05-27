#frozen_string_literal: true

class ProfileRepository
  class << self

    def create(user_id, token, expires_at)
      RegistrationToken.create!(user_id: user_id, token: token, expires_at: expires_at)
    end

    def find_by_user_id(user_id)
      Profile.find_by(user_id: user_id)
    end
  end
end
