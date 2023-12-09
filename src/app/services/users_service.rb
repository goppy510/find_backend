# frozen_string_literal: true

class UsersService
  class << self
    include SessionModule
    include Contracts::ContractsError

    def show(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      raise Contracts::ContractsError::Forbidden if !PermissionService.has_user_role?(user_id)

      member_data = Contracts::UsersDomain.show(user_id, target_user_id)
      return nil if member_data.blank?

      user = UserRepository.find_by_id(target_user_id)
      {
        id: user.id,
        email: user.email,
        activated: user.activated,
        created_at: user.created_at.strftime('%Y-%m-%d %H:%M:%S'),
        updated_at: user.updated_at.strftime('%Y-%m-%d %H:%M:%S')
      }
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    def index(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      user_id = authenticate_user(token)[:user_id]
      raise Contracts::ContractsError::Forbidden if !PermissionService.has_user_role?(user_id)

      members_data = Contracts::UsersDomain.index(user_id)
      return nil if members_data.blank?

      response = []
      users = User.where(id: members_data.map(&:user_id))
      users.each do |user|
        response << {
          id: user.id,
          email: user.email,
          activated: user.activated,
          created_at: user.created_at.strftime('%Y-%m-%d %H:%M:%S'),
          updated_at: user.updated_at.strftime('%Y-%m-%d %H:%M:%S')
        }
      end
      response
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    def destroy(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      raise Contracts::ContractsError::Forbidden if !PermissionService.has_user_role?(user_id)

      Contracts::UsersDomain.destroy(user_id, target_user_id)
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end
  end
end
