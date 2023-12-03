# frozen_string_literal: true

class UsersService
  class Forbidden < StandardError; end
  class << self
    include SessionModule

    def show(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      raise Forbidden if !PermissionService.has_user_role?(user_id)

      domain = Contracts::UsersDomain.show(user_id, target_user_id)
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    def index(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      user_id = authenticate_user(token)[:user_id]
      raise Forbidden if !PermissionService.has_user_role?(user_id)

      domain = Contracts::UsersDomain.index(user_id)
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    def destroy(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      raise Forbidden if !PermissionService.has_user_role?(user_id)

      domain = Contracts::UsersDomain.destroy(user_id, target_user_id)
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end
  end
end
