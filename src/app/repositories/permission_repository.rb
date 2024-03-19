# frozen_string_literal: true

class PermissionRepository
  class << self
    def create(user_id, permissions = [])
      return if permissions.blank?

      resources = Resource.where(name: permissions)
      return if resources.blank?

      permission_data = resources.map { |resource| { user_id:, resource_id: resource.id } }
      Permission.insert_all(permission_data)
    end

    def index_all
      Permission.joins(:resource, :user)
                .joins('JOIN contract_memberships cm ON cm.user_id = permissions.user_id')
                .joins('JOIN contracts c ON c.id = cm.contract_id')
                .select('users.email, users.id AS user_id, resources.name AS resource_name, c.id AS contract_id')
                .distinct
    end

    def index(user_id)
      # 契約者のユーザーIDに基づいて契約IDとそのメンバーのユーザーIDを取得
      contract_members_info = ContractMembership
                              .joins(:contract)
                              .where(contracts: { user_id: })
                              .select(:user_id, 'contracts.id as contract_id')

      # 上記で取得したメンバーのユーザーIDに基づくPermissionを取得
      Permission.joins(:resource, :user)
                .where(user_id: contract_members_info.map(&:user_id))
                .select('users.email, users.id AS user_id, resources.name AS resource_name, contracts.id AS contract_id')
                .distinct
    end

    def show(user_id)
      Permission.joins(:resource).where(user_id:).pluck('resources.name')
    end

    def update(user_id, permissions = [])
      return if permissions.blank?

      # 現在のユーザーの権限を取得
      current_permissions = Permission.where(user_id: user_id).includes(:resource)
      current_permission_names = current_permissions.map { |permission| permission.resource.name }

      # 削除が必要な権限を識別
      permissions_to_remove = current_permission_names - permissions
      resources_to_remove = Resource.where(name: permissions_to_remove)
      Permission.where(user_id: user_id, resource: resources_to_remove).delete_all

      # 新規挿入が必要な権限を識別
      permissions_to_add = permissions - current_permission_names
      resources_to_add = Resource.where(name: permissions_to_add)

      permission_data = resources_to_add.map { |resource| { user_id: user_id, resource_id: resource.id } }
      Permission.insert_all(permission_data) unless permission_data.empty?
    end

    def destroy(user_id, permissions = [])
      resource_ids = Resource.where(name: permissions).pluck(:id)
      Permission.where(user_id:, resource_id: resource_ids).destroy_all
    end
  end
end
