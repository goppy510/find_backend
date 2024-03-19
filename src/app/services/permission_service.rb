# frozen_string_literal: true

class PermissionService
  class << self
    include SessionModule
    include Permissions::PermissionError

    # @param [String] token
    # @param [String] target_user_email
    # @param [Array] permissions
    # @return [Array]
    def create(token, target_user_email, permissions)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_emailがありません' if target_user_email.blank?
      raise ArgumentError, 'permissionsがありません' if permissions.blank?

      target_user_id = UserRepository.find_by_email(target_user_email).id
      raise Permissions::PermissionError::Forbidden unless target_user_id.present?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_permisssion_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Permissions::PermissionError::Forbidden
      end

      # 管理者権限ならtrue, それ以外は対象ユーザーと自分自身の契約IDが一致しているならtrue
      is_own_user = PermissionService.has_admin_role?(user_id) ? true : is_own_user?(user_id, target_user_id)
      raise Permissions::PermissionError::Forbidden unless is_own_user

      Permissions::PermissionDomain.create(target_user_id, permissions)
    end

    # @param [String] token
    # @return [Array]
    def index(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_contract_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Permissions::PermissionError::Forbidden
      end

      permissions = PermissionService.has_admin_role?(user_id) ? Permissions::PermissionDomain.index_all : Permissions::PermissionDomain.index(user_id)
      grouped_permissions = format_permissions(permissions)
      return nil if permissions.blank?

      grouped_permissions
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    # @param [String] token
    # @param [String] target_user_id
    # @return [Array]
    def show(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      # 自分自身の場合は権限チェックせずにレスポンスを返す
      return Permissions::PermissionDomain.show(target_user_id) if user_id == target_user_id.to_i

      if !PermissionService.has_permisssion_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Permissions::PermissionError::Forbidden
      end

      is_own_user = own_user?(user_id, target_user_id)
      raise Permissions::PermissionError::Forbidden unless is_own_user

      Permissions::PermissionDomain.show(target_user_id)
    end

    # @param [String] token
    # @param [String] target_user_email
    # @param [Array] permissions
    # @return [Array]
    def update(token, target_user_email, permissions)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_emailがありません' if target_user_email.blank?
      raise ArgumentError, 'permissionsがありません' if permissions.blank?

      target_user_id = UserRepository.find_by_email(target_user_email).id
      raise Permissions::PermissionError::Forbidden if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_permisssion_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Permissions::PermissionError::Forbidden
      end

      # 管理者権限ならtrue, それ以外は対象ユーザーと自分自身の契約IDが一致しているならtrue
      is_own_user = PermissionService.has_admin_role?(user_id) ? true : own_user?(user_id, target_user_id)
      raise Permissions::PermissionError::Forbidden unless is_own_user

      Permissions::PermissionDomain.update(target_user_id, permissions)
    end

    def destroy(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_permisssion_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Permissions::PermissionError::Forbidden
      end

      is_own_user = is_own_user?(user_id, target_user_id)
      raise Permissions::PermissionError::Forbidden unless is_own_user

      Permissions::PermissionDomain.destroy(target_user_id, permissions)
    end

    def has_admin_role?(user_id)
      raise ArgumentError, 'user_idがありません' if user_id.blank?

      self_permission(user_id).include?('admin')
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

    def has_read_prompt_role?(user_id)
      raise ArgumentError, 'user_idがありません' if user_id.blank?

      self_permission(user_id).include?('read_prompt')
    end

    def has_create_prompt_role?(user_id)
      raise ArgumentError, 'user_idがありません' if user_id.blank?

      self_permission(user_id).include?('create_prompt')
    end

    def has_update_prompt_role?(user_id)
      raise ArgumentError, 'user_idがありません' if user_id.blank?

      self_permission(user_id).include?('update_prompt')
    end

    def has_destroy_prompt_role?(user_id)
      raise ArgumentError, 'user_idがありません' if user_id.blank?

      self_permission(user_id).include?('destroy_prompt')
    end

    private

    # 自分の権限表示
    def self_permission(user_id)
      PermissionRepository.show(user_id)
    end

    # 対象ユーザーが自身の契約と紐づいているユーザーかチェックする
    def own_user?(user_id, target_user_id)
      raise ArgumentError, 'user_idがありません' if user_id.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      owner_contract = ContractRepository.show(user_id)
      return false if owner_contract.blank?

      res = ContractMembershipRepository.show(target_user_id, owner_contract.id)
      res.present?
    end

    def format_permissions(permissions)
      grouped_permissions = permissions.each_with_object({}) do |permission, hash|
        user_id = permission.user_id
        # user_idをキーとして使わず、ユーザー毎の情報を格納
        hash[user_id] ||= { user_id:, email: permission.email, contract_id: permission.contract_id,
                            permissions: [] }
        hash[user_id][:permissions] << permission.resource_name
      end
      # ハッシュの値だけを配列として返す
      grouped_permissions.values
    end
  end
end
