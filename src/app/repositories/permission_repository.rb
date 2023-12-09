# frozen_string_literal: true

class PermissionRepository
  class << self
    def create(user_id, permissions = [])
      return if permissions.blank?

      resources = Resource.where(name: permissions)
      return if resources.blank?

      permission_data = resources.map { |resource| { user_id: user_id, resource_id: resource.id } }
      Permission.insert_all(permission_data)
    end

    def show(user_id)
      Permission.joins(:resource)
                .where(user_id: user_id)
                .pluck('resources.name')
    end

    def destroy(user_id, permissions = [])
      resource_ids = Resource.where(name: permissions).pluck(:id)
      Permission.where(user_id: user_id, resource_id: resource_ids).destroy_all
    end
  end
end
