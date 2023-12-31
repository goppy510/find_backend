# frozen_string_literal: true

class PermissionService
  class << self
    include SessionModule
    include Permissions::PermissionError

    def create(token, target_user_id, permissions)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?
      raise ArgumentError, 'permissionsがありません' if permissions.blank?

      user_id = authenticate_user(token)[:user_id]
      raise Permissions::PermissionError::Forbidden unless has_permisssion_role?(user_id)

      Permissions::PermissionDomain.create(target_user_id, permissions)
    end

    def show(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      raise Permissions::PermissionError::Forbidden unless has_permisssion_role?(user_id)

      return Permissions::PermissionDomain.show(target_user_id)
    end

    def destroy(token, target_user_id, permissions)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?
      raise ArgumentError, 'permissionsがありません' if permissions.blank?

      user_id = authenticate_user(token)[:user_id]
      raise Permissions::PermissionError::Forbidden unless has_permisssion_role?(user_id)

      Permissions::PermissionDomain.destroy(target_user_id, permissions)
    end

    def has_contract_role?(user_id)
      raise ArgumentError, 'user_idがありません' if user_id.blank?

      self_permission(user_id).include?('contract')
    end

    def has_permisssion_role?(user_id)
      raise ArgumentError, 'user_idがありません' if user_id.blank?

      self_permission(user_id).include?('permission')
    end

    def has_user_role?(user_id)
      raise ArgumentError, 'user_idがありません' if user_id.blank?

      self_permission(user_id).include?('user')
    end

    private

    # 自分の権限表示
    def self_permission(user_id)
      PermissionRepository.show(user_id)
    end
  end
end
