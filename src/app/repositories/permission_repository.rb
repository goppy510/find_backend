# frozen_string_literal: true

class PermissionRepository
  class << self
    def upsert(user_id, permissions = {})
      # permissions[:resource] から resource_ids を取得します。
      desired_resource_ids = Resource.where(name: permissions[:resource]).pluck(:id)
      
      # Upsert
      if desired_resource_ids.present?
        Permission.upsert_all(
          desired_resource_ids.map do |resource_id|
            {
              user_id:,
              resource_id:
            }
          end
        )
      end
      
      # Delete
      # user_id に関連する全ての resource_ids を取得する
      existing_resource_ids = Permission.where(user_id: user_id).pluck(:resource_id)
      
      # desired_resource_ids に含まれない resource_ids を削除する
      ids_to_remove = existing_resource_ids - desired_resource_ids
      
      if ids_to_remove.present?
        Permission.where(user_id: user_id, resource_id: ids_to_remove).destroy_all
      end
    end

    def show(user_id)
      Permission.joins(:resource)
                .where(user_id: user_id)
                .pluck('resources.name')
    end
  end
end
