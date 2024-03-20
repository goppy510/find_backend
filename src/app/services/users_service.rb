# frozen_string_literal: true

class UsersService
  class << self
    include SessionModule
    include Members::UsersError
    include Permissions::PermissionError

    def index(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_user_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Members::UsersError::Forbidden
      end

      # 管理者権限ならtrue, それ以外は対象ユーザーと自分自身の契約IDが一致しているならtrue
      is_own_user = PermissionService.has_admin_role?(user_id) ? true : is_own_user?(user_id, target_user_id)
      raise Permissions::PermissionError::Forbidden unless is_own_user

      members_data = PermissionService.has_admin_role?(user_id) ? Members::UsersDomain.index_all : Members::UsersDomain.index(user_id)
      return nil if members_data.blank?

      response = []
      members_data.each do |user|
        response << {
          contract_id: user.contract_id,
          user_id: user.user_id,
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

    def show(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_user_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Members::UsersError::Forbidden
      end

      member_data = Members::UsersDomain.show(user_id, target_user_id)
      return nil if member_data.blank?

      user = UserRepository.find_by_id(target_user_id)
      {
        user_id: user.id,
        email: user.email,
        activated: user.activated,
        created_at: user.created_at.strftime('%Y-%m-%d %H:%M:%S'),
        updated_at: user.updated_at.strftime('%Y-%m-%d %H:%M:%S')
      }
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    def destroy(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_user_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Members::UsersError::Forbidden
      end

      Members::UsersDomain.destroy(target_user_id)
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    private

    # 対象ユーザーが自身の契約と紐づいているユーザーかチェックする
    def own_user?(user_id, target_user_id)
      raise ArgumentError, 'user_idがありません' if user_id.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      owner_contract = ContractRepository.show(user_id)
      return false if owner_contract.blank?

      res = ContractMembershipRepository.show(target_user_id, owner_contract.id)
      res.present?
    end
  end
end
