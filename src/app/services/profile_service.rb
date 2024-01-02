# frozen_string_literal: true

class ProfileService
  class << self
    include SessionModule

    def create(token, profiles)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'profilesがありません' if profiles.blank?

      user_id = authenticate_user(token)[:user_id]
      Profiles::ProfileDomain.create(user_id, profiles)
    end

    def update(token, profiles)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'profilesがありません' if profiles.blank?

      user_id = authenticate_user(token)[:user_id]
      Profiles::ProfileDomain.update(user_id, profiles)
    end

    def show(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      user_id = authenticate_user(token)[:user_id]
      Profiles::ProfileDomain.show(user_id)
    end
  end
end
